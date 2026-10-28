#!/usr/bin/env python3
"""Example headless PyMOL structure fetching and ray-traced rendering."""
import os
import sys

def main():
    try:
        import pymol
        from pymol import cmd
    except ImportError:
        print("Error: pymol Python module is not available in environment.", file=sys.stderr)
        sys.exit(1)

    print("Initializing PyMOL in headless mode...")
    # pymol.finish_launching(['pymol', '-cq'])

    output_png = "1crn_rendered.png"
    print("Fetching PDB 1crn...")
    cmd.fetch("1crn", type="pdb")

    print("Configuring representation...")
    cmd.hide("everything")
    cmd.show("cartoon")
    cmd.color("cyan", "ss h")
    cmd.color("magenta", "ss s")
    cmd.color("orange", "ss l+")
    cmd.zoom()

    print("Ray-tracing structure...")
    cmd.ray(800, 600)
    cmd.png(output_png)
    print(f"Rendered image saved to {output_png}")

if __name__ == "__main__":
    main()
