# Turnkey Starkit/Starpack builder
# By KETNAR on github 1/19/2026
# This was a royal bitch to get working because the documentation out there is fragmented,
# outdated, links broken, and then you have inactivestate 'helping' for their
# SaaS business model, because hobbyists be damned. (fucking Ew?)
#
# The tcl comunity has a major problem with www bitrot and just plain garbage web-design 
# from the 90s making valid/updated information near impossible to centralise and obsorb
# So hear me when I say: Yo Tclers out there in TV land! Get your shit together or your 
# favorite lang is gonna be toast because nobody is gonna use it anymore. 
#
# And this is coming from a guy who LIKES weird esoteric little-used langs. :P
# ----------------------------------
# Usage:
#   Run from the project root with a Tcl shell, e.g.:
#     c:/tcl/bin/tclsh.exe Starkit_builder/build.tcl
#
# What this does:
#   - Creates a clean VFS tree under Starkit_builder/work/<app>.vfs
#   - Copies the files listed in a project file list into that VFS
#     (this instance expects a file named WinFileList in the project root)
#   - Writes a main.tcl launcher inside the VFS
#   - Builds a .kit (Starkit)
#   - Builds a .exe (Starpack) if a suitable runtime is available
#
# Key configuration knobs:
#   tcl_root
#     Root directory of your Tcl installation. This is used to locate
#     sdx.kit and, by default, a tclkit runtime to embed into the .exe.
#
#   STARKIT_RUNTIME (environment variable, optional)
#     If set, this must point to a starpack-capable runtime (e.g. a
#     tclkit or basekit .exe or .kit). When present and valid, it
#     overrides the default runtime detection below.
#
#   Default runtime
#     If STARKIT_RUNTIME is not set, the script will look for:
#       $tcl_root/bin/tclkit-win64-tk.exe
#     and, if found, use that as the embedded runtime for the .exe.
#
# Tcl distribution expectations:
#   This instance is designed to run against a BAWT
#   "Tcl 8.6.17 Batteries Included (64 bit)" installation from:
#     https://www.bawt.tcl3d.org/download.html#tclbi
#   with that install rooted at c:/tcl.
#   But it should work with any fully complete TCL install that 
#   contains all the bits and bobs.
#
# Outputs:
#   Starkit_builder/<app>.kit  - self-contained Starkit
#   Starkit_builder/<app>.exe  - Windows EXE (if runtime found)
#
# PS: If you dump ResourceHacker.exe in the same dir as this file, you can update the resulting 
#     exe to use any ico file you want. Otherwise it will just carry on without this step.

set script_dir [file dirname [file normalize [info script]]]
set project_root [file dirname $script_dir]
set tcl_root "c:/tcl"
set sdx_kit [file join $tcl_root bin sdx.kit]
set runtime_exe ""
set work_root [file join $script_dir "work"]
set kit_root [file join $work_root "Trebuchet.vfs"]
set output_dir $script_dir
set output_kit [file join $output_dir "Trebuchet.kit"]
set output_exe [file join $output_dir "Trebuchet.exe"]
if {[info exists ::env(STARKIT_RUNTIME)] && $::env(STARKIT_RUNTIME) ne ""} {
    if {[file exists $::env(STARKIT_RUNTIME)]} {
        set runtime_exe $::env(STARKIT_RUNTIME)
    }
}
if {$runtime_exe eq ""} {
    set default_runtime [file join $tcl_root bin tclkit-win64-tk.exe]
    if {[file exists $default_runtime]} {
        set runtime_exe $default_runtime
    }
}
proc ensure_dir {path} {
    if {![file isdirectory $path]} {
        file mkdir $path
    }
}
proc empty_dir {path} {
    if {[file exists $path]} {
        file delete -force $path
    }
    file mkdir $path
}
proc copy_file_list {project_root kit_root} {
    set filelist_path [file join $project_root WinFileList]
    if {![file exists $filelist_path]} {
        error "WinFileList not found at $filelist_path"
    }
    set fh [open $filelist_path r]
    set lines [split [read $fh] "\n"]
    close $fh
    foreach rel [lsort -unique $lines] {
        set rel [string trim $rel]
        if {$rel eq ""} {
            continue
        }
        set src [file join $project_root $rel]
        set dst [file join $kit_root $rel]
        set dst_dir [file dirname $dst]
        if {![file exists $src]} {
            continue
        }
        ensure_dir $dst_dir
        file copy -force $src $dst
    }
}
proc copy_tls {tcl_root kit_root} {
    set tls_dir [file join $tcl_root lib tls2.0b3]
    if {![file isdirectory $tls_dir]} {
        return
    }
    set dest_parent [file join $kit_root lib]
    ensure_dir $dest_parent
    set dest [file join $dest_parent tls2.0b3]
    if {[file exists $dest]} {
        file delete -force $dest
    }
    file copy -force -- $tls_dir $dest
}
proc write_main {kit_root} {
    set main_path [file join $kit_root "main.tcl"]
    set fh [open $main_path w]
    puts $fh {set here [file dirname [file normalize [info script]]]}
    puts $fh {if {[info exists ::starkit::topdir]} {
    set app_root $::starkit::topdir
} else {
    set app_root $here
}}
    puts $fh {set libdir [file join $app_root lib]}
    puts $fh {if {[file isdirectory $libdir]} {
    if {[lsearch -exact $::auto_path $libdir] < 0} {
        lappend ::auto_path $libdir
    }
}}
    puts $fh {set ::argv0 [file join $app_root Trebuchet.tcl]}
    puts $fh {cd $app_root}
    puts $fh {source $::argv0}
    close $fh
}
empty_dir $work_root
empty_dir $kit_root
copy_file_list $project_root $kit_root
copy_tls $tcl_root $kit_root
write_main $kit_root
if {![file exists $sdx_kit]} {
    error "sdx.kit not found at $sdx_kit"
}
if {[file exists $output_kit]} {
    file delete -force $output_kit
}
if {[file exists $output_exe]} {
    file delete -force $output_exe
}
set cmd [list [info nameofexecutable] $sdx_kit wrap $output_kit -vfs $kit_root]
set code [catch {eval exec $cmd} result]
if {$code != 0} {
    puts stderr "sdx wrap for kit failed: $result"
    exit 1
}
if {$runtime_exe ne ""} {
    set cmd [list [info nameofexecutable] $sdx_kit wrap $output_exe -vfs $kit_root -runtime $runtime_exe]
    set code [catch {eval exec $cmd} result]
    if {$code != 0} {
        puts stderr "sdx wrap for exe failed: $result"
        exit 1
    }
    set res_hacker [file join $script_dir "ResourceHacker.exe"]
    set ico_path [file join $project_root "icons" "Treb.ico"]
    if {[file exists $res_hacker] && [file exists $ico_path]} {
        set rh_cmd [list $res_hacker -open $output_exe -save $output_exe -action addoverwrite -res $ico_path -mask ICONGROUP,MAINICON,]
        set rh_code [catch {eval exec $rh_cmd} rh_result]
        if {$rh_code != 0} {
            puts stderr "warning: ResourceHacker icon update failed: $rh_result"
        }
    } elseif {[file exists $ico_path]} {
        puts stderr "note: ResourceHacker.exe not found, skipping icon update"
    } elseif {[file exists $res_hacker]} {
        puts stderr "note: Treb.ico not found, skipping icon update"
    }
}
exit 0

