(
f = { |x| (x * 2).sin * 3 + (x * 0.3).sin };

p = Pbind(
    \dev, Ptime().collect(f), // current time passed to function
    \midinote, Pkey(\dev) + 60 + [0, 4],
    \amp, 0.05,
    \dur, 0.15
).play;
)



~freqs = FileReader.read("C:\\Users\\Camilo\\partiels\\freqs.txt")


~amps = FileReader.read("C:\\Users\\Camilo\\partiels\\amps.txt")

~amps.asFloat.plot()