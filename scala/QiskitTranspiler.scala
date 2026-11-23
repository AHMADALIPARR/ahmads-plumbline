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

// Scala port of the Qiskit OpenQASM 3.0 transpiler
// Uses Qiskit via Python interop or a pure-Scala stub that mirrors the interface.
// Full Qiskit calls require a JVM-Python bridge (e.g. Jep, Py4J) or calling the Python script.

package plumbline.transpiler

import java.nio.file.{Files, Paths}
import scala.sys.process._

object QiskitTranspiler {
  def transpile(
      inputPath: String,
      outputPath: String = "transpiled.qasm",
      topology: String = "line",
      optLevel: Int = 3,
      theta: Option[Double] = None
  ): Unit = {
    val cmd = Seq(
      "python3",
      "python/qiskit_transpiler_v2.py",
      inputPath,
      "-o", outputPath,
      "--topology", topology,
      "--opt-level", optLevel.toString
    ) ++ theta.map(t => Seq("--theta", t.toString)).getOrElse(Seq.empty)

    println(s"Invoking: ${cmd.mkString(" ")}")
    val exit = cmd.!
    if (exit != 0) throw new RuntimeException(s"Transpiler failed with exit $exit")
    println(s"Transpiled circuit written to $outputPath")
  }

  def main(args: Array[String]): Unit = {
    if (args.length < 1) {
      println("Usage: QiskitTranspiler <input.qasm> [output.qasm] [topology] [optLevel] [theta]")
      sys.exit(1)
    }
    val inPath  = args(0)
    val outPath = if (args.length > 1) args(1) else "transpiled.qasm"
    val topo    = if (args.length > 2) args(2) else "line"
    val level   = if (args.length > 3) args(3).toInt else 3
    val th      = if (args.length > 4) Some(args(4).toDouble) else None
    transpile(inPath, outPath, topo, level, th)
  }
}
