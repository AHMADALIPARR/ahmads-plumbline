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

import Control.Exception (bracket)
import Control.Monad (foldM)
import Data.Int (Int64)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Sequence (Seq (..), (|>))
import qualified Data.Sequence as Seq
import Foreign.C.Types (CInt (..), CSize (..))
import Foreign.Marshal.Alloc (alloca)
import Foreign.Ptr (Ptr, nullPtr)
import Foreign.Storable (poke)

-- | Opaque handle to a C Term node managed by raw_gc.
data CTerm

tagInt, tagVar, tagCons :: CInt
tagInt  = 0
tagVar  = 1
tagCons = 2

-- Raw GC FFI
foreign import ccall unsafe "raw_gc.h gc_init"
  c_gc_init :: CSize -> IO ()

foreign import ccall unsafe "raw_gc.h gc_push_root"
  c_gc_push_root :: Ptr (Ptr CTerm) -> IO ()

foreign import ccall unsafe "raw_gc.h gc_pop_roots"
  c_gc_pop_roots :: CSize -> IO ()

foreign import ccall unsafe "raw_gc.h gc_alloc"
  c_gc_alloc :: CInt -> IO (Ptr CTerm)

foreign import ccall unsafe "raw_gc.h gc_collect"
  c_gc_collect :: IO ()

-- Term accessors
foreign import ccall unsafe "raw_gc.h term_tag"
  c_term_tag :: Ptr CTerm -> IO CInt

foreign import ccall unsafe "raw_gc.h term_set_int"
  c_term_set_int :: Ptr CTerm -> Int64 -> IO ()

foreign import ccall unsafe "raw_gc.h term_get_int"
  c_term_get_int :: Ptr CTerm -> IO Int64

foreign import ccall unsafe "raw_gc.h term_bind_var"
  c_term_bind_var :: Ptr CTerm -> Ptr CTerm -> IO ()

foreign import ccall unsafe "raw_gc.h term_get_binding"
  c_term_get_binding :: Ptr CTerm -> IO (Ptr CTerm)

-- | Register a temporary root slot for the duration of an IO action.
withRoot :: Ptr CTerm -> IO a -> IO a
withRoot term action = alloca $ \slot -> do
  poke slot term
  bracket
    (c_gc_push_root slot)
    (\_ -> c_gc_pop_roots 1)
    (\_ -> action)

-- | Dereference a chain of bound TAG_VAR nodes.
deref :: Ptr CTerm -> IO (Ptr CTerm)
deref p = do
  tag <- c_term_tag p
  if tag /= tagVar
    then pure p
    else do
      next <- c_term_get_binding p
      if next == nullPtr then pure p else deref next

-- ---------------------------------------------------------------------------
-- Minimal Parlog Mode-Suspension Scheduler
-- ---------------------------------------------------------------------------

data Mode = In | Out deriving (Eq, Show)

data Goal = Goal
  { goalPred  :: String
  , goalModes :: [Mode]
  , goalArgs  :: [Ptr CTerm]
  }

data SchedState = SchedState
  { runnable  :: !(Seq Goal)
  , suspended :: !(Map (Ptr CTerm) [Goal]) -- keyed by unbound TAG_VAR
  }

-- | Returns Left unboundVar if any In (?) argument is unbound; Right () if ready.
checkInputs :: Goal -> IO (Either (Ptr CTerm) ())
checkInputs g = foldM step (Right ()) (zip (goalModes g) (goalArgs g))
  where
    step (Left v) _      = pure (Left v)
    step (Right ()) (Out, _) = pure (Right ())
    step (Right ()) (In, arg) = do
      t <- deref arg
      tag <- c_term_tag t
      pure $ if tag == tagVar then Left t else Right ()

-- | Bind a Parlog output variable and wake all goals suspended on it.
bindVar :: Ptr CTerm -> Ptr CTerm -> SchedState -> IO SchedState
bindVar varPtr valPtr st = do
  c_term_bind_var varPtr valPtr
  let (woken, remaining) =
        Map.updateLookupWithKey (\_ _ -> Nothing) varPtr (suspended st)
      newRunnable = foldl (|>) (runnable st) (concat woken)
  pure st { runnable = newRunnable, suspended = remaining }

-- | Commit and execute a ready goal (stands in for SGML-loaded clause dispatch).
reduceGoal :: Goal -> SchedState -> IO SchedState
reduceGoal g st = case (goalPred g, goalArgs g) of
  ("produce", [outVar]) -> do
    v <- c_gc_alloc tagInt
    c_term_set_int v 42
    putStrLn "produce/1 committed: binding X = 42"
    bindVar outVar v st
  ("consume", [inArg]) -> do
    t <- deref inArg
    n <- c_term_get_int t
    putStrLn $ "consume/1 committed: received " <> show n
    pure st
  _ -> error $ "Unknown goal: " <> goalPred g

-- | Round-robin AND-parallel scheduler loop.
runScheduler :: SchedState -> IO ()
runScheduler st = case runnable st of
  Empty ->
    if Map.null (suspended st)
      then putStrLn "All Parlog goals succeeded."
      else putStrLn $ "Deadlock: " <> show (Map.size (suspended st)) <> " blocked var(s)."
  g :<| rest -> do
    let st' = st { runnable = rest }
    ready <- checkInputs g
    case ready of
      Left blockingVar -> do
        putStrLn $ goalPred g <> " suspended on unbound variable"
        let susp' = Map.insertWith (++) blockingVar [g] (suspended st')
        runScheduler st' { suspended = susp' }
      Right () -> do
        st'' <- reduceGoal g st'
        runScheduler st''

main :: IO ()
main = do
  c_gc_init 1024
  x <- c_gc_alloc tagVar -- shared Parlog stream/logic variable
  withRoot x $ do
    -- Enqueue consumer *before* producer to demonstrate mode suspension & wakeup
    let gConsume = Goal "consume" [In]  [x]
        gProduce = Goal "produce" [Out] [x]
    runScheduler SchedState
      { runnable  = Seq.fromList [gConsume, gProduce]
      , suspended = Map.empty
      }
  c_gc_collect
