require "fileutils"


class Nispack

   VERSION = "1.0.0"
   SIGNATURE = "NISPACK\0\0\0\0\0".force_encoding("binary")

   attr_reader :filename
   attr_reader :file
   attr_reader :entries

   def initialize(name, file, entries)
      @name = name
      @file = file
      @entries = entries
   end

   def self.open(filename)
      name = File.basename(filename)
      file = File.new(filename, "rb")
      if file.read(SIGNATURE.bytesize) != SIGNATURE
         raise "#{filename} is not a Nispack: wrong signature."
      end
      n_entries = file.read(4).unpack('l')[0]
      entries = Array.new(n_entries)
      entries.map! do |entry|
         entry = Hash.new
         entry[:name] = file.read(32).strip
         entry[:start] = file.read(4).unpack('l')[0]
         entry[:size] = file.read(4).unpack('l')[0]
         file.pos += 4
         entry
      end
      file.pos = 0
      nispack = self.new(name, file, entries)
      if block_given?
         yield nispack
         nispack.close
      else
         return nispack
      end
   end

   def close
      @file.close
   end

   def extract_all(dir = File.basename(@name).chomp(File.extname(@name)))
      old_dir = Dir.pwd
      FileUtils.mkdir_p(dir)
      FileUtils.cd(dir)
      @entries.each {|entry| extract_entry(entry)}
      FileUtils.cd(old_dir)
   end

   def extract(name)
      entry = @entries.select{|x| x[:name] == name}.first
      if entry.nil?
         raise "Can't extract #{name}: not in the Nispack archive"
      end
      extract_entry(entry)
   end

   def extract_entry(entry)
      File.open(entry[:name], "wb") do |out|
         @file.pos = entry[:start]
         out.write(@file.read(entry[:size]))
         @file.pos = 0
      end
   end

   private :extract_entry

   def self.create_from_directory(options)
      dir = options[:dir] || Dir.pwd
      name = options[:name] || File.basename(Dir.pwd) + ".DAT"
      files = Dir.entries(dir).select{|f| File.file?(File.join(dir, f))}
      out = File.new(name, "wb+")
      out.write(SIGNATURE)
      out.write([files.size].pack("l"))
      start = 16 + 44 * files.size
      files.each do |f|
         out.write([f].pack("a32"))
         out.write([start].pack("l"))
         size = File.size(File.join(dir, f))
         out.write([size].pack("l"))
         out.write([0].pack("l"))
         start += size
      end
      files.each do |f|
         out.write(IO.binread(File.join(dir, f)))
      end
      out.close
   end

   
end
