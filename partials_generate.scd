(
~freqs = FileReader.read("C:\\Users\\Camilo\\partiels\\freqs.txt").asFloat;
~envs = FileReader.read("C:\\Users\\Camilo\\partiels\\envs.txt").asFloat;
~tmps = FileReader.read("C:\\Users\\Camilo\\partiels\\tmps.txt").asFloat;
//~freqs = FileReader.read("/Users/camilo/partiels/freqs.txt").asFloat;
//~envs = FileReader.read("/Users/camilo/partiels/envs.txt").asFloat;
//~temps = FileReader.read("/Users/camilo/partiels/tmps.txt").asFloat;
~nf = ~freqs.size;
)

s.meter
s.plotTree
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
)
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
SynthDef(\EnvNoise, {
	arg mode=0.0, atk=0.01, ampdb=0, qf=100, decay=0.1, freq=440, chan=0;
	var sig, env, mod;
	mod =  BPF.kr(BrownNoise.kr(mode, 0.0),4.0, add:1.0);
	env = EnvGen.kr(Env.new([0,1,0],[atk,decay],[1,-1]),doneAction:2);
	sig = Resonz.ar(WhiteNoise.ar(ampdb.dbamp), freq, bwr:qf.reciprocal);
	sig = sig*env*mod;
	Out.ar(chan, sig);
}).add;
)

(
~po = Array.fill(~nf,{arg i; i});
~ps = ~po.scramble;
~l1 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0,~np),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(0,~np),
	\partiel, Pseq(~po),
	\chan,0,
);
~l1b = Pbind(
	\instrument, \EnvSin2,
	\dur, Pn(0,~np),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(-10,~np),
	\freq, Pseq(~freqs),
	\amps, Pseq(~envs),
	\tmp, Pseq(~tmps),
	\chan,0,
);
~l2 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0.06,~np),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\ampdb, Pn(0,~np),
	\partiel, Pseq(~ps),
	\chan,0,
);
~l3 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0,~np),
	\mode, Pseq(Array.fill(~nf,{arg i; 0.8 - (i*0.8/~nf)})),
	\atk, 20.0,
	\sus,3.0,
	\ampdb, Pn(0,~np),
	\partiel, Pseq(~po),
	\chan,0,
);
)

Pbind.free

~l1.play(); // og
~l1b.play(); // og
~l2.play(); // arp
~l3.play();