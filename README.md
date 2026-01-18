# THIS IS A FORK FROM OFFICAL [TREBUCHET](https://github.com/fuzzball-muck/trebuchet)

    "Why? Because fork you, that's why."

## But no really, why?
Trebuchet is my fave mu-client. I can take it from one OS to the next and not have to worry about it.  It's simple, effective, and has the features I need for what I'm doing.

Sadly, it has been lacking in updates just a touch too long, and now it's tls/ssl support seems to break on updated(? Different?) TCL installs on some oses.
It still seems to work on old activestate TCL windows installs, but as nobody can download tcl/tk for windows from Activestate anymore because activestate went full SaaS-cancer mode, 
and oh look, tons and tons of comunity downloads WERE hosted on the activestate website, which are all DEAD now..

..Then nobody updates the old websites..

Now TCL life is painful. 

(Thanks activestate. You suck by the way.)

### Okay, and then?
  
Then I switched to a different TCl/tk install for some machines, and all *hell* broke loose where Trebuchet was concerned. SSL took a complete nose dive, file loads were freaking out. 

ttk errors!

THE LOGO WAS NOT PERFECTLY CENTERED.

It was madness. MADNESS! 

So I went snooping into the code.

    "Well I guess I could fix that for myself.."
    "This bug isn't too bad.."
    "Oh, I could fix this too. pffh, ez mode."

# And down the rabbit hole I went.

And now here we are, you poor sod.

Anyways, I'm running this against BAWT `Tcl 8.6.17 Batteries Included (64 bit)` from [here](https://www.bawt.tcl3d.org/download.html#tclbi) which is pretty nice, truth be told. 
(I like it, at least. And I hate eveyrthing.), at least for windows machines. *nix machines i'm just running it rawdog off whatever 8.6+ TCL/tk is included in the OS.

YMMV, but probabbly (hopefully?) not.

I'm mostly just going to chase down bugfixes, and maybe nail a todo here or there if it's something I might find handy. 
This is practically a 'for my own use' git, but I figured i'd leave it open so anybody else who might want to use it can, and maybe the treb devs can pull something useful out of it.

Don't open an issue without a detailed error log or details or steps to recreate, i'll just ignore it or Probabbly delete it.  :]
