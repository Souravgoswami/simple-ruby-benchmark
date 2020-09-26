# Define a pad method on float class, which returns a string of with padded zeroes
Float.define_method(:pad) do |digits = 3|
	self.round(digits).to_s.then do |x|
		x.split(?..freeze).then { |y| "#{y[0]}.#{(y[1].length < digits ? y[1] + '0'.freeze.*(digits - y[1].length).freeze : y[1])}" }
	end
end

# Benchmark methods
module Benchmark
	# Don't use class << self for indentation issues

	# Use Benchmark.benchmark!('string') for timed results
	def self.benchmark!(string = nil, &block)
		str = string ? "#{string}" : "Time taken".freeze

		t = Time.now
		block.call(self)
		total_time = Time.now - t
		total_time_rounded = total_time.round(3)

		puts "#{str} #{total_time_rounded.pad}s"
		total_time_rounded
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

	def self.initialize_words
		if SORTED_WORDS.empty?
			word_file = File.join(__dir__, 'wordlist')
			unless File.exist?(word_file)
				puts ":: Downloading the words..."
				require 'net/https'

				IO.write(word_file, Net::HTTP.get(URI('https://raw.githubusercontent.com/Souravgoswami/simple-ruby-benchmark/master/wordlist')))
			end

			IO.readlines(word_file).each(&:downcase!).tap(&:uniq!).each do |w|
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
end

# Benchmark unless required in other files
if __FILE__ == $0
	require 'io/console'
	puts "\e[1;38;2;255;80;80m:: Details:\e[0m"
	puts "Ruby Version: #{RUBY_VERSION} (#{RUBY_PLATFORM})\n\n"
	puts "CFLAGS: #{RbConfig::CONFIG['CFLAGS']}"

	puts ?- * STDOUT.winsize[1]

	puts "\e[1;38;2;255;200;0m:: Please stop all your apps, perhaps reboot your system, and run the benchmark\e[0m"
	puts "\e[1;38;2;255;200;0m:: Don't even move your mouse during the benchmark for consistent result!\e[0m"


	###################################################

	GC.compact if GC.respond_to?(:compact)
	sleep 1
	puts "Hunting for anagrams"
	Benchmark.initialize_words

	time = 0
	10.times do |x|
		time += Benchmark.benchmark!(":: Anagram Search Iteration #{x.next}:") do
			%w(esalr rotets nmsee overt laemsens terganil caahimglnlooypr ealrsdo earsengt).each do |word|
				Benchmark.anagram_hunt(word)
			end
		end
	end

	require 'io/console'

	puts "Total time taken: #{time.pad(3)}s"
	puts ?- * STDOUT.winsize[1]

	###################################################

	GC.compact if GC.respond_to?(:compact)
	sleep 1
	puts "Calculating 8,000,000 prime numbers"
	total_time = 0

	time = 0
	10.times do |x|
		time += Benchmark.benchmark!(":: Prime Iteration #{x.next}:") { Benchmark.prime(8_000_000) }
	end

	puts "Total time taken: #{time.pad(3)}s"
	puts ?- * STDOUT.winsize[1]

	###################################################

	GC.compact if GC.respond_to?(:compact)
	sleep 1
	puts "Calculating 5000 digits of Pi"
	total_time = 0

	time = 0
	10.times do |x|
		time += Benchmark.benchmark!(":: Pi Iteration #{x.next}:") { Benchmark.pi(5000) }
	end

	puts "Total time taken: #{time.pad(3)}s"
	puts ?- * STDOUT.winsize[1]
end
