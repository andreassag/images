"""PyMOL startup python script for publication presets and utilities."""
import pymol
from pymol import cmd

# Configure high-quality rendering
cmd.set("ray_trace_mode", 1)
cmd.set("antialias", 2)
