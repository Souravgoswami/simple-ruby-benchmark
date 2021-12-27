#!/usr/bin/ruby -w
#
# Supports Ruby 2.1 and above
#
# Tested Ruby till date: 2.1.9 to 3.1.0
# [ All newly tested ruby may not be added above in the future ]
# Open an issue in case your bleeding edge MRuby can't run this code.
#
# You can copy paste this code to a simple file.
# Install ruby.
# Run the file you pasted the code with ruby.
#
# This will downloads a 5 MB word file if not present
# Delete this code once you're done!

# Define methods if used Ruby 2.5
Kernel.class_exec { define_method(:then) { |&block| block === self } } unless Kernel.respond_to?(:then)

# Define a pad method on float class, which returns a string of with padded zeroes
class Float
	def pad(digits = 3)
		"%0.#{digits}f" % self
	end
end

# Benchmark methods
module Benchmark
	# Don't use class << self for indentation issues

	# Use Benchmark.benchmark!('string') for timed results
	def self.benchmark!(string = nil, &block)
		str = string ? "#{string}" : "Time taken".freeze

		t, cpu_t = Process.clock_gettime(Process::CLOCK_MONOTONIC), Process.times
		block.call(self)
		t2, cpu_t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC), Process.times

		total_time = t2 - t
		cpu_time = cpu_t2.utime.+(cpu_t2.stime).-(cpu_t.utime + cpu_t.stime)

		puts "#{str} Real Time: #{total_time.pad}s | CPU Time: #{cpu_time.pad}"
		[
			total_time.round(3),
			cpu_time.round(3)
		]
	end

	# Calculate prime
	def self.prime(range)
	    (numbers = (2..range).to_a.unshift(nil, nil)).each do |num|
		next if num.nil?
		return numbers.tap(&:compact!) if (sqr = num ** 2) > range
		sqr.step(range, num) { |x| numbers[x] = nil }
	    end
	end

	# Calculate Primes
	def self.pi(n)
		q, r, t, k, m, x, str = 1, 0, 1, 1, 3, 3, ''

		if 4 * q + r - t < m * t
			str.concat(m.to_s)
			q, r, m = 10 * q, 10 * (r - m * t), (10 * (3 * q + r)) / t - 10 * m
		else
			q, r, t, k, m, x = q * k, (2 * q + r) * x, t * x, k + 1, (q * (7 * k + 2) + r * x) / (t * x), x + 2
		end while str.length < n

		str[1, 0] = '.'
		str
	end

	# Intialize anagram words before anagram hunting
	SORTED_WORDS, WORDS = [], []
	ALL_WORDS = ''

	# Should be run prior to blowfish, and anagram test
	def self.initialize_wordlist(word_file = File.join(__dir__, 'wordlist'))
		if ALL_WORDS.empty?
			unless File.exist?(word_file)
				puts ":: Downloading the words..."
				require 'net/https'
				IO.write(word_file, Net::HTTP.get(URI('https://raw.githubusercontent.com/Souravgoswami/simple-ruby-benchmark/master/wordlist')))
			end

			ALL_WORDS.replace(IO.read(word_file))
		end
	end

	# Should be run prior to anagram test
	def self.initialize_words
		if SORTED_WORDS.empty?
			word_file = File.join(__dir__, 'wordlist')
			initialize_wordlist(word_file)

			ALL_WORDS.split(?\n).each(&:downcase!).tap(&:uniq!).each do |w|
				w.strip!

				unless w[/[^a-z]/]
					WORDS << w
					SORTED_WORDS << w.split(''.freeze).sort.join
				end
			end
		end

		nil
	end

	# Anagram hunting
	def self.anagram_hunt(word)
		initialize_words

		term = word.split(''.freeze).sort.join
		i = -1
		x = []
		x << WORDS[i] if SORTED_WORDS[i] == term while SORTED_WORDS[i += 1]
		x
	end

	def self.blowfish
		word_file = File.join(__dir__, 'wordlist')
		initialize_wordlist(word_file)

		require 'openssl'
		cipher = OpenSSL::Cipher.new('bf-cbc').tap(&:encrypt)
		cipher.key = key = 16.times.map { [rand(97..122).chr, rand(0..9)].sample }.join
		encrypted_data = cipher.update(ALL_WORDS) << cipher.final

		cipher = OpenSSL::Cipher.new('bf-cbc').tap(&:decrypt)
		cipher.key = key
		decrypted_data = cipher.update(encrypted_data) << cipher.final

		ALL_WORDS == decrypted_data
	end

	def self.fibonacci(n)
		a, b, i = 1, 0, -1
		a, b = b, a + b while (i += 1) < n
		a
	end

	def self.fpu_test(n)
		x, n, i = 1.0, n + 1.0, 0.0

		while (i += 1.0) < n
			x *= -1
			x /= i
			x += i.%(2.0).==(0.0) ? 1.0 : -1.0
			x -= i.%(2.0).==(0.0) ? -1.0 : 1.0
		end

		x
	end

	def self.string_concat(n)
		str, i, n = '', 0, n + 1
		str << 'c' while (i += 1) < n
		nil
	end
end

# Benchmark unless required in other files
if __FILE__ == $0
	require 'io/console'
	puts "\e[1;38;2;255;80;80m:: Details:\e[0m"
	puts "Ruby Version: #{RUBY_VERSION} (#{RUBY_PLATFORM})\n\n"
	puts "CC: #{RbConfig::CONFIG['CC']}"
	puts "CFLAGS: #{RbConfig::CONFIG['CFLAGS']}"

	puts ?- * STDOUT.winsize[1]

	puts "\e[1;38;2;255;200;0m:: Please stop all your apps, perhaps reboot your system, and run the benchmark\e[0m"
	puts "\e[1;38;2;255;200;0m:: Don't even move your mouse during the benchmark for consistent result!\e[0m"

	anim_time = Time.now
	delay = 3
	anim_delay = delay.to_f / (STDOUT.winsize[1])

	anims = %w(| / - \\)

	STDOUT.winsize[1].-(12).times do |x|
		print "\e[2K#{anims.rotate![0]} #{"Ready? (#{delay - Time.now.-(anim_time).to_i.next})"}#{?..*(x)}\r"
		sleep anim_delay
	end

	puts

	$all_test_real_time, $all_test_cpu_time, $total_tests = 0, 0, 0

	def standard_benchmark(iterations: 10, message_head:, message_body:)
		GC.compact if GC.respond_to?(:compact)
		puts message_head

		real_time = 0
		cpu_time = 0

		iterations.times do |x|
			times = Benchmark.benchmark!(":: #{message_body} Iteration #{x.next}:") { yield }
			real_time += times[0]
			cpu_time += times[1]
		end

		$all_test_real_time += real_time
		$all_test_cpu_time += cpu_time

		$total_tests += 1

		puts "Total: Real Time #{real_time.pad(3)}s | CPU Time #{cpu_time.pad(3)}s"
		puts ?- * STDOUT.winsize[1]

		sleep 1
	end

	Benchmark.initialize_wordlist
	standard_benchmark(message_head: 'CPU Blowfish Test', message_body: 'CPU Blowfish') do
		Benchmark.blowfish
	end

	standard_benchmark(message_head: 'FPU Test', message_body: 'FPU Math') do
		Benchmark.fpu_test(2_000_000)
	end

	standard_benchmark(message_head: 'CPU Fibonacci Test', message_body: 'CPU Fibonacci') do
		Benchmark.fibonacci(200_000)
	end

	Benchmark.initialize_words
	standard_benchmark(message_head: 'CPU Anagram Hunt', message_body: 'CPU Anagram') do
		%w(esalr rotets nmsee overt laemsens terganil caahimglnlooypr ealrsdo earsengt).each do |word|
			Benchmark.anagram_hunt(word)
		end
	end

	standard_benchmark(message_head: 'CPU 2 Million Prime Numbers', message_body: 'Prime Numbers') do
		Benchmark.prime(2_000_000)
	end

	standard_benchmark(message_head: 'CPU 2k Pi Digits', message_body: '2K Pi Digits') do
		Benchmark.pi(2000)
	end

	standard_benchmark(message_head: 'String Concat 1M', message_body: 'String Concat 1M') do
		Benchmark.string_concat(1_000_000)
	end

	puts "Total Tests: #{$total_tests}"
	puts "Total Test CPU Time: #{$all_test_cpu_time.round(3)}s | Avg Test CPU Time: #{$all_test_cpu_time.fdiv($total_tests).round(3)}s"
	puts "Total Test Real Time: #{$all_test_real_time.round(3)}s | Avg Test Real Time: #{$all_test_real_time.fdiv($total_tests).round(3)}s"
end
