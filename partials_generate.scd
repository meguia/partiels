
//~freqs = FileReader.read("C:\\Users\\Camilo\\partiels\\freqs.txt")
//~amps = FileReader.read("C:\\Users\\Camilo\\partiels\\amps.txt")

(
~freqs = FileReader.read("/Users/camilo/partiels/freqs.txt").asFloat;
~amps = FileReader.read("/Users/camilo/partiels/amps.txt").asFloat;
~nf = ~freqs.size;
~np = ~amps[0].size;
)

s.meter
s.plotTree
s.options.memSize = 8192*32;

(
SynthDef(\EnvSin, {
	arg partiel=0, rate=100.0, chan=0, ampdb=0;
	var sig, env, freq = Select.kr(partiel,~freqs)[0];
	var amp = Select.kr(partiel,~amps);
	env = EnvGen.kr(Env.new(amp,(1/rate)!~np),doneAction:2);
	sig = SinOsc.ar(freq, mul: ampdb.dbamp);
	sig = sig*env;
	Out.ar(chan, sig);
}).add;
)


(
~po = Array.fill(~nf,{arg i; i});
~ps = ~po.scramble;
~l1 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0,~np),
	\rate, Pn(20,~np),
	\ampdb, Pn(0,~np),
	\partiel, Pseq(~po),
	\chan,0,
);
~l2 = Pbind(
	\instrument, \EnvSin,
	\dur, Pn(0.05,~np),
	\ampdb, Pn(0,~np),
	\rate, Pn(30,~np),
	\partiel, Pseq(~ps),
	\chan,0,
);
)




~l1.play(); // og
~l2.play(); // arp