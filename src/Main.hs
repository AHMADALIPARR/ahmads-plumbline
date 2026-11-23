========================================================================
; SOVEREIGN LEVIATHAN NODE LICENSE
; License-ID: SL-AGPL3-001 | Covenant-Version: 1.0
; SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
; Copyright (C) 2026 SnapKittyWest. Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust.
; ========================================================================
;
; This file is a covered work under the GNU Affero General Public License,
; version 3, together with the Sovereign Leviathan additional terms.
;
; Hark, though this node be but a spark,
; Its covenant endureth through the dark.
;
; Ignorantia juris non excusat.
; ========================================================================

{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Control.Concurrent (Chan, MVar, forkIO, newChan, newEmptyMVar, newMVar, putMVar, readChan, takeMVar, withMVar, writeChan)
import Control.Exception (bracket)
import Control.Monad (forM_, forever, void, when)
import Data.Char (isAlphaNum, isSpace)
import Data.Int (Int64)
import Data.List (dropWhileEnd, isPrefixOf)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Foreign.C.Types (CInt (..), CSize (..))
import Foreign.Marshal.Alloc (alloca)
import Foreign.Ptr (Ptr, nullPtr)
import Foreign.Storable (poke)

-- ---------------------------------------------------------------------------
-- 1. Raw GC FFI Bindings
-- ---------------------------------------------------------------------------

data CTerm

tagInt, tagVar, tagCons :: CInt
tagInt  = 0
tagVar  = 1
tagCons = 2

foreign import ccall unsafe "raw_gc.h gc_init"         c_gc_init         :: CSize -> IO ()
foreign import ccall unsafe "raw_gc.h gc_push_root"    c_gc_push_root    :: Ptr (Ptr CTerm) -> IO ()
foreign import ccall unsafe "raw_gc.h gc_pop_roots"    c_gc_pop_roots    :: CSize -> IO ()
foreign import ccall unsafe "raw_gc.h gc_alloc"        c_gc_alloc        :: CInt -> IO (Ptr CTerm)
foreign import ccall unsafe "raw_gc.h gc_collect"      c_gc_collect      :: IO ()
foreign import ccall unsafe "raw_gc.h term_tag"        c_term_tag        :: Ptr CTerm -> IO CInt
foreign import ccall unsafe "raw_gc.h term_set_int"    c_term_set_int    :: Ptr CTerm -> Int64 -> IO ()
foreign import ccall unsafe "raw_gc.h term_get_int"    c_term_get_int    :: Ptr CTerm -> IO Int64
foreign import ccall unsafe "raw_gc.h term_bind_var"   c_term_bind_var   :: Ptr CTerm -> Ptr CTerm -> IO ()
foreign import ccall unsafe "raw_gc.h term_get_binding":: Ptr CTerm -> IO (Ptr CTerm)

-- ---------------------------------------------------------------------------
-- 2. SGML Parser (for parlog.dtd)
-- ---------------------------------------------------------------------------

data SNode
  = SElem String [(String, String)] [SNode]
  | SText String
  deriving (Show)

data Mode = In | Out deriving (Eq, Show)

data TermAst
  = TInt Int64
  | TNil
  | TVar String
  deriving (Show)

data AtomAst = AtomAst String [TermAst] deriving (Show)

data Clause = Clause
  { clHead  :: AtomAst
  , clGuard :: [AtomAst]
  , clBody  :: [AtomAst]
  } deriving (Show)

data Program = Program
  { progModes   :: Map (String, Int) [Mode]
  , progClauses :: [Clause]
  } deriving (Show)

emptyElements :: [String]
emptyElements = ["arg", "var"]

stripProlog :: String -> String
stripProlog s
  | "<!--" `isPrefixOf` s = stripProlog (dropComment s)
  | "<!"   `isPrefixOf` s = stripProlog (drop 1 (dropWhile (/= '>') s))
  | otherwise             = s
  where
    dropComment ('-':'-':'>':xs) = xs
    dropComment (_:xs)           = dropComment xs
    dropComment []               = []

parseAttrs :: String -> ([(String, String)], String)
parseAttrs input = go (dropWhile isSpace input) []
  where
    go [] acc = (reverse acc, [])
    go ('>':xs) acc = (reverse acc, xs)
    go xs acc =
      let (k, r1) = span (\c -> isAlphaNum c || c == '_' || c == '-') xs
          r2      = dropWhile (\c -> isSpace c || c == '=') r1
          (v, r3) = case r2 of
            ('"':rest) -> let (val, after) = break (== '"') rest
                          in (val, drop 1 after)
            _          -> span (not . (\c -> isSpace c || c == '>')) r2
      in go (dropWhile isSpace r3) ((k, v) : acc)

parseNodes :: String -> ([SNode], String)
parseNodes [] = ([], [])
parseNodes s =
  let s' = stripProlog (dropWhile isSpace s)
  in case s' of
    [] -> ([], [])
    ('<':'/':rest) -> ([], drop 1 (dropWhile (/= '>') rest))
    ('<':rest) ->
      let (tag, afterTag) = span (\c -> isAlphaNum c || c == '_' || c == '-') rest
          (attrs, afterAttrs) = parseAttrs afterTag
      in if tag `elem` emptyElements
           then let (sibs, remStr) = parseNodes afterAttrs
                in (SElem tag attrs [] : sibs, remStr)
           else let (kids, afterClose) = parseNodes afterAttrs
                    (sibs, remStr)     = parseNodes afterClose
                in (SElem tag attrs kids : sibs, remStr)
    _ ->
      let (txt, rest) = break (== '<') s'
          trimmed     = dropWhileEnd isSpace txt
          (sibs, remStr) = parseNodes rest
      in if null trimmed
           then (sibs, remStr)
           else (SText trimmed : sibs, remStr)

lowerProgram :: [SNode] -> Program
lowerProgram nodes =
  case [kids | SElem "program" _ kids <- nodes] of
    (kids:_) -> Program (Map.fromList (concatMap toMode kids)) (concatMap toClause kids)
    []       -> error "Missing <program> root element"
  where
    toMode (SElem "mode" attrs kids) =
      let predName = maybe "" id (lookup "pred" attrs)
          dirs     = [ if lookup "dir" a == Just "out" then Out else In
                     | SElem "arg" a _ <- kids ]
      in [((predName, length dirs), dirs)]
    toMode _ = []

    toClause (SElem "clause" _ kids) =
      let hd = head [a | SElem "head" _ cs <- kids, a <- map toAtom cs]
          gd = [a | SElem "guard" _ cs <- kids, a <- map toAtom cs]
          bd = [a | SElem "body"  _ cs <- kids, a <- map toAtom cs]
      in [Clause hd gd bd]
    toClause _ = []

    toAtom (SElem "atom" attrs kids) =
      AtomAst (maybe "" id (lookup "pred" attrs)) (map toTerm kids)
    toAtom other = error $ "Expected <atom>, got " <> show other

    toTerm (SElem "term" _ [SText "nil"])             = TNil
    toTerm (SElem "term" _ [SText n])                 = TInt (read n)
    toTerm (SElem "term" _ [SElem "var" attrs _])     = TVar (maybe "_" id (lookup "name" attrs))
    toTerm other = error $ "Unsupported <term>: " <> show other

parseParlogSGML :: String -> Program
parseParlogSGML = lowerProgram . fst . parseNodes

-- ---------------------------------------------------------------------------
-- 3. Oz Concurrent Stack + Dataflow Runtime
-- ---------------------------------------------------------------------------

data StackOp
  = Push (Ptr CTerm)
  | Pop  (Ptr CTerm) -- unbound TAG_VAR; server binds it when popped

data Runtime = Runtime
  { rtHeapLock :: MVar ()
  , rtWakeups  :: MVar (Map (Ptr CTerm) [MVar ()])
  , rtStack    :: Chan StackOp
  }

withHeap :: Runtime -> IO a -> IO a
withHeap rt = withMVar (rtHeapLock rt) . const

deref :: Ptr CTerm -> IO (Ptr CTerm)
deref p = do
  t <- c_term_tag p
  if t /= tagVar then pure p else do
    nxt <- c_term_get_binding p
    if nxt == nullPtr then pure p else deref nxt

-- | Bind an Oz/Parlog dataflow variable and wake all threads awaiting it.
bindDataflow :: Runtime -> Ptr CTerm -> Ptr CTerm -> IO ()
bindDataflow rt varPtr valPtr = do
  withHeap rt $ c_term_bind_var varPtr valPtr
  waiters <- modifyMVarMap (rtWakeups rt) varPtr
  mapM_ (`putMVar` ()) waiters
  where
    modifyMVarMap mv k = do
      m <- takeMVar mv
      let (found, m') = Map.updateLookupWithKey (\_ _ -> Nothing) k m
      putMVar mv m'
      pure (concat found)

-- | Oz dataflow read: suspends current thread if varPtr is unbound.
awaitBound :: Runtime -> Ptr CTerm -> IO (Ptr CTerm)
awaitBound rt p = do
  d <- withHeap rt (deref p)
  t <- withHeap rt (c_term_tag d)
  if t /= tagVar
    then pure d
    else do
      sig <- newEmptyMVar
      m <- takeMVar (rtWakeups rt)
      putMVar (rtWakeups rt) (Map.insertWith (++) d [sig] m)
      -- Re-check after registering to avoid lost wakeups
      d2 <- withHeap rt (deref d)
      t2 <- withHeap rt (c_term_tag d2)
      when (t2 == tagVar) $ takeMVar sig
      awaitBound rt d

-- | Oz Concurrent Stack server (Port + internal stack state).
startOzStack :: Runtime -> IO (Chan StackOp)
startOzStack rt = do
  ch <- newChan
  void $ forkIO (loop [] ch)
  pure ch
  where
    loop stk ch = do
      op <- readChan ch
      case op of
        Push v -> do
          d <- awaitBound rt v
          n <- withHeap rt (c_term_get_int d)
          putStrLn $ "[OzStack] push " <> show n
          loop (d : stk) ch
        Pop replyVar -> case stk of
          (top:rest) -> do
            n <- withHeap rt (c_term_get_int top)
            putStrLn $ "[OzStack] pop  " <> show n
            bindDataflow rt replyVar top
            loop rest ch
          [] -> do
            -- Re-queue Pop if stack is currently empty (non-blocking Oz port)
            writeChan ch (Pop replyVar)
            loop [] ch

-- ---------------------------------------------------------------------------
-- 4. Parlog AND-Parallel Interpreter
-- ---------------------------------------------------------------------------

evalGoal :: Runtime -> Program -> Map String (Ptr CTerm) -> AtomAst -> IO ()
evalGoal rt prog env (AtomAst predName args) = do
  ptrs <- mapM (materializeTerm rt env) args
  case (predName, ptrs) of
    ("push", [valPtr]) -> writeChan (rtStack rt) (Push valPtr)
    ("pop",  [outVar]) -> writeChan (rtStack rt) (Pop outVar)
    ("print", [inVar]) -> do
      v <- awaitBound rt inVar
      n <- withHeap rt (c_term_get_int v)
      putStrLn $ "[Parlog] print -> " <> show n
    _ -> do
      -- Match first clause in Program, commit, and spawn body in AND-parallel
      let matching = [ c | c@(Clause (AtomAst h _) _ _) <- progClauses prog, h == predName ]
      case matching of
        (Clause _ _ body : _) -> do
          -- Committed-choice: spawn all body goals in AND-parallel
          dones <- mapM (\g -> do
            done <- newEmptyMVar
            void $ forkIO (evalGoal rt prog env g >> putMVar done ())
            pure done) body
          mapM_ takeMVar dones
        [] -> error $ "No matching Parlog clause for " <> predName

materializeTerm :: Runtime -> Map String (Ptr CTerm) -> TermAst -> IO (Ptr CTerm)
materializeTerm rt env term = case term of
  TInt n -> withHeap rt $ do
    p <- c_gc_alloc tagInt
    c_term_set_int p n
    pure p
  TVar name -> case Map.lookup name env of
    Just p  -> pure p
    Nothing -> error $ "Unbound SGML variable: " <> name
  TNil -> withHeap rt (c_gc_alloc tagVar)

-- ---------------------------------------------------------------------------
-- 5. Demo: SGML-defined AND-Parallel Producers/Consumers on Oz Stack
-- ---------------------------------------------------------------------------

sampleSGML :: String
sampleSGML = unlines
  [ "<!DOCTYPE program SYSTEM \"parlog.dtd\">"
  , "<program>"
  , "  <mode pred=\"main\"><arg dir=\"out\"></mode>"
  , "  <clause>"
  , "    <head><atom pred=\"main\"><term><var name=\"R\"></term></atom></head>"
  , "    <guard></guard>"
  , "    <body>"
  , "      <atom pred=\"pop\"><term><var name=\"R\"></term></atom>"
  , "      <atom pred=\"push\"><term>42</term></atom>"
  , "      <atom pred=\"print\"><term><var name=\"R\"></term></atom>"
  , "    </body>"
  , "  </clause>"
  , "</program>"
  ]

main :: IO ()
main = do
  c_gc_init 2048
  hLock <- newMVar ()
  wakes <- newMVar Map.empty
  ch    <- newChan
  let rt0 = Runtime hLock wakes ch
  stkCh <- startOzStack rt0
  let rt   = rt0 { rtStack = stkCh }
      prog = parseParlogSGML sampleSGML

  rVar <- withHeap rt (c_gc_alloc tagVar)
  alloca $ \slot -> do
    poke slot rVar
    bracket (c_gc_push_root slot) (\_ -> c_gc_pop_roots 1) $ \_ ->
      evalGoal rt prog (Map.singleton "R" rVar) (AtomAst "main" [TVar "R"])

  withHeap rt c_gc_collect
