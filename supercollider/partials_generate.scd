(
//~freqs = FileReader.read("C:\\Users\\Camilo\\partiels\\freqs.txt").asFloat;
//~envs = FileReader.read("C:\\Users\\Camilo\\partiels\\envs.txt").asFloat;
//~tmps = FileReader.read("C:\\Users\\Camilo\\partiels\\tmps.txt").asFloat;
~freqs = FileReader.read("/Users/camilo/partiels/freqs.txt").asFloat;
~envs = FileReader.read("/Users/camilo/partiels/envs.txt").asFloat;
~tmps = FileReader.read("/Users/camilo/partiels/tmps.txt").asFloat;
~nf = ~freqs.size;
)


s.meter
s.plotTree
~nk = NanoKontrol2();
s.options.memSize = 8192*32;

//// FUNCTIONS ////
(
~tempoCh = {
	arg clock, nTempo, nBeats;
	var i = 0, tempoArr;
	tempoArr = Array.interpolation(nBeats, clock.tempo, nTempo/60);
	clock.schedAbs(clock.nextBar, {
		clock.tempo_(tempoArr[i]);
		i = i+1;
		if(i < nBeats) {1}{\done.postln};
	});
};
)


//// SYNTHS ///////

(
SynthDef(\EnvSin, {
	arg partiel=0, ampdb=0, mode=0, atk=1.0,sus=1.0,rel=1.0, chan=0;
	var sig, env, mod, freq = Select.kr(partiel,~freqs)[0];
	var tmp = Select.kr(partiel,~tmps)*[atk,sus,rel];
	mod =  BPF.kr(BrownNoise.kr(mode, 0.0),4.0, add:1.0);
	env = EnvGen.kr(Env.new(Select.kr(partiel,~envs),tmp,[1,0,-6]),doneAction:2);
	sig = SinOsc.ar(freq, mul: ampdb.dbamp);
	sig = sig*env*mod;
	Out.ar(chan, sig);
}).add;
SynthDef(\EnvNoise, {
	arg partiel=0, ampdb=0, mode=0.0, atk=1.0, sus=1.0, rel=1.0, qf=100, chan=0;
	var sig, env, mod, freq = Select.kr(partiel,~freqs)[0];
	var tmp = Select.kr(partiel,~tmps)*[atk,sus,rel];
	mod =  BPF.kr(BrownNoise.kr(mode, 0.0),4.0, add:1.0);
	env = EnvGen.kr(Env.new(Select.kr(partiel,~envs),tmp,[1,0,-6]),doneAction:2);
	sig = Resonz.ar(PinkNoise.ar(ampdb.dbamp), freq, bwr:qf.reciprocal);
	sig = sig*env*mod;
	Out.ar(chan, sig);
}).add;
SynthDef(\CEnvSin, {
	arg mode=0.0, atk=0.01, decay=0.2, amp=1.0, harm=10.0, chan=0;
	var sig=0, env, mod, amps=Harmonics(5).decay(harm);
	env = EnvGen.kr(Env.new([0,1,0],[atk,decay],[1,-1]),doneAction:2);
	mod =  BPF.kr(BrownNoise.kr(mode, 0.0),4.0, add:1.0);
	5.do { |n|
		sig = sig + SinOsc.ar(Select.kr(NamedControl.kr(\p ++ (n+1), 1),~freqs), mul: amps[n]);
	};
	sig = sig*env*mod*amp;
	Out.ar(chan, sig);
}).add;
)

// THIS should work
(
SynthDef(\EnvSin2, {
	arg ampdb=0, mode=0, freq=440, amps=#[1e-8,0.1,0.03,1e-8], tmp=#[0.01,0.1,1.0], chan=0;
	var sig, env, mod;
	mod =  BPF.kr(BrownNoise.kr(mode, 0.0),4.0, add:1.0);
	env = EnvGen.kr(Env.new(amps,tmp,[1,0,-6]),doneAction:2);
	sig = SinOsc.ar(freq, mul: ampdb.dbamp);
	sig = sig*env*mod;
	Out.ar(chan, sig);
}).add;
)


(
~l1b = Pbind(
	\instrument, \EnvSin2,
	\dur, Pn(0,~nf),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(-30,~nf),
	\freq, Pseq(~freqs),
	\amps, Pseq(~envs),
	\tmp, Pseq(~tmps),
	\chan,0,
).play();
)
/// FIXED PATTERNS

(
~po = Array.fill(~nf,{arg i; i});
~ps = ~po.scramble;
~l1 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0,~nf),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(0,~nf),
	\partiel, Pseq(~po),
	\chan,0,
);
~l1b = Pbind(
	\instrument, \EnvSin2,
	\dur, Pn(0,~nf),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(-20,~nf),
	\freq, Pseq(~freqs),
	\amps, Pseq(~envs),
	\tmp, Pseq(~tmps),
	\chan,0,
);
~l2 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0.06,~nf),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(0,~nf),
	\partiel, Pseq(~ps),
	\chan,0,
);
~n1 = Pbind(
	\instrument, \EnvNoise,
	\dur, Pn(0,~nf),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(35,~nf),
	\qf, Pn(300,~nf),
	\partiel, Pseq(~po),
	\chan,0,
);
~l3 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0.1,~nf),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\atk, 20.0,
	\sus,3.0,
	\ampdb, Pn(0,~nf),
	\partiel, Pseq(~ps),
	\chan,0,
);
~n3 = Pbind(
	\instrument, \EnvNoise,
	\dur, Pn(0,~nf),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\atk, 20.0,
	\sus,3.0,
	\ampdb, Pn(30,~nf),
	\qf, Pn(300,~nf),
	\partiel, Pseq(~po),
	\chan,0,
);
)


~l1.play(); // og
~l1b.play(); // og version b
~l2.play(); // arp
~l3.play(); // bow
~n1.play();  // noise
~n3.play();  // noise


//initial Gains and Harmonics
(
~g1 = 0.001;~g2 = 0.001;~g3 = 0.001;~g4 = 0.001;~g5 = 0.001;~g6 = 0.001;~g7 = 0.001;~g8 = 0.001;
~h1 = 10.0;~h2 = 10.0;~h3 = 10.0;~h4 = 10.0;~h5 = 10.0;~h6 = 10.0;~h7 = 10.0;~h8 = 10.0;
)

////// PATTERNS  /////// ONE BY ONE
Pbindef.clear;

(
Pbindef(\cenv1,
	\instrument, \CEnvSin,
	\dur, Pwhite(0.5,3.0,inf),
	\atk, Pwhite(0.1,0.9,inf),
	\decay, Pwhite(1.7,6.0,inf),
	\mode, Pwhite(0.5,1.0,inf),
	\p1, Pwrand([0,1,2,3,4],[0.5,0.1,0.2,0.1,0.2].normalizeSum,inf),
	\p2, Pwrand([2,3,1,5,6],[0.5,0.1,0.1,0.1,0.2].normalizeSum,inf),
	\p3, Prand([7,8,9,10,11],inf),
	\p4, Prand([12,13,14,15],inf),
	\p5, Prand([16,17,18,19],inf),
	\harm, Pfunc({~h1}),
	\amp, Pfunc({~g1}),
	\chan, 0,
);
)
(
Pbindef(\cenv2,
	\instrument, \CEnvSin,
	\dur, Pwhite(0.5,3.0,inf),
	\atk, Pwhite(0.1,0.5,inf),
	\decay, Pwhite(0.9,5.0,inf),
	\mode, Pwhite(0.5,1.0,inf),
	\p1, Pwrand([0,1,2,3,4],[0.1,0.5,0.1,0.2,0.2].normalizeSum,inf),
	\p2, Pwrand([2,3,1,5,6],[0.1,0.5,0.1,0.2,0.2].normalizeSum,inf),
	\p3, Prand([7,8,9,10,11],inf),
	\p4, Prand([12,13,14,15],inf),
	\p5, Prand([16,17,18,19],inf),
	\harm, Pfunc({~h2}),
	\amp, Pfunc({~g2}),
	\chan, 0,
);
)

(
Pbindef(\perp1,
	\instrument, \CEnvSin,
	\dur, Pseq([3.0,1.0],inf), // Prand
	\atk, Pseq([0.002,0.003],inf),
	\decay, Pseq([0.8,0.6],inf), // Prand
	\mode, Pseq([0.5,0.5],inf),
	\p1, Pseq([0],inf),
	\p2, Pseq([1],inf),
	\p3, Prand([2,3],inf),
	\p4, Prand([4,5],inf),
	\p5, Pseq([6],inf),
	\harm, Pfunc({~h3}),
	\amp, Pfunc({~g3}),
	\chan,0,
);
)

(
Pbindef(\third1,
	\instrument, \CEnvSin,
	\dur, Prand([1/3,2/3],inf), // Prand
	\atk, Pseq([0.001,0.001],inf),
	\decay, Pseq([0.2,0.15],inf),
	\mode, Pseq([0.4,0.2],inf),
	\p1, Pseq([10],inf),
	\p2, Pseq([11],inf),
	\p3, Pseq([12],inf),
	\p4, Pseq([13],inf),
	\p5, Pseq([14],inf),
	\harm, Pfunc({~h5}),
	\amp, Pfunc({~g5}),
	\chan,0,
);
)

(
Pbindef(\tingle1,
	\instrument, \CEnvSin,
	\dur, Pwrand([0.125,0.25,0.5],[0.1,0.5,0.5].normalizeSum,inf),
	\atk, Pseq([0.001],inf),
	\decay, Pseq([0.1],inf),
	\mode, Pseq([0.4],inf),
	\p1, Pseq([10],inf),
	\p2, Pseq([11],inf),
	\p3, Prand([13,11],inf),
	\p4, Prand([16,15],inf),
	\p5, Prand([14,15,17,18],inf),
	\harm, Pfunc({~h7}),
	\amp, Pfunc({~g7}),
	\chan,0,
);
)

(
~nk.knob1.onChange = {|val| ~g1 = val.linexp(0,127,0.001,1.0);};
~nk.knob2.onChange = {|val| ~g2 = val.linexp(0,127,0.001,1.0);};
~nk.fader1.onChange = {|val| ~h1 = val.linexp(0,127,10.0,1.0);};
~nk.fader2.onChange = {|val| ~h2 = val.linexp(0,127,10.0,1.0);};
)

(
Pbindef(\cenv1).fadeTime = 3.0;
Pbindef(\cenv2).fadeTime = 3.0;
)

// TEMPO START CLOCK
t.stop;
t = TempoClock(20/60);

(
~nk.knob3.onChange = {|val| ~g3 = val.linexp(0,127,0.001,0.6);};
~nk.knob4.onChange = {|val| ~g4 = val.linexp(0,127,0.001,0.6);};
~nk.knob5.onChange = {|val| ~g5 = val.linexp(0,127,0.001,0.6);};
~nk.knob6.onChange = {|val| ~g6 = val.linexp(0,127,0.001,0.6);};
~nk.knob7.onChange = {|val| ~g7 = val.linexp(0,127,0.001,0.6);};
~nk.knob8.onChange = {|val| ~g8 = val.linexp(0,127,0.001,0.6);};
~nk.fader3.onChange = {|val| ~h3 = val.linexp(0,127,10.0,1.0);};
~nk.fader4.onChange = {|val| ~h4 = val.linexp(0,127,10.0,1.0);};
~nk.fader5.onChange = {|val| ~h5 = val.linexp(0,127,10.0,1.0);};
~nk.fader6.onChange = {|val| ~h6 = val.linexp(0,127,10.0,1.0);};
~nk.fader7.onChange = {|val| ~h7 = val.linexp(0,127,10.0,1.0);};
~nk.fader8.onChange = {|val| ~h8 = val.linexp(0,127,10.0,1.0);};
)

// SECOND PART CONTROLS 2-8 start at 0
(
Pbindef(\perp1).play(t, quant: Quant(4));
Pbindef(\third1).play(t, quant: Quant(4,1));
Pbindef(\tingle1).play(t, quant: Quant(4,1));
Pbindef(\tingle1).play(t, quant: Quant(4,1));
)
// START LONG NOTES CCONTROL 1,2
(
Pbindef(\cenv1).play(t);
Pbindef(\cenv2).play(t);
)

~tempoCh.(t,90, 20);
