# encoding: utf-8
# frozen_string_literal: true

module MultiExiftool

  # Represents option for the ExifTool command-line application
  class Options

    # ExifTool option +-b+ (+-binary+) Output metadata in binary format
    attr_accessor :b

    # ExifTool option <code>-c FMT</code> (+-coordFormat+) Set format for GPS coordinates
    attr_accessor :c

    # ExifTool option <code>-charset exif=CHARSET</code> Specify encoding for special characters
    attr_accessor :exif_charset

    # ExifTool option <code>-charset id3=CHARSET</code> Specify encoding for special characters
    attr_accessor :id3_charset

    # ExifTool option <code>-charset iptc=CHARSE</code> Specify encoding for special characters
    attr_accessor :iptc_charset

    # ExifTool option <code>-charset photoshop=CHARSET</code> Specify encoding for special characters
    attr_accessor :photoshop_charset

    # ExifTool option <code>-charset quicktime=CHARSET</code> Specify encoding for special characters
    attr_accessor :quicktime_charset

    # ExifTool option <code>-charset riff=CHARSET</code> Specify encoding for special characters
    attr_accessor :riff_charset

    # Exiftool option +-g[NUM...]+ (+-groupHeadings+) Organize output by tag group
    attr_accessor :g

    # ExifTool option <code>-lang [LANG]</code> Set current language
    attr_accessor :lang

    # ExifTool option +-n+ (+--printConv+) No print conversion
    attr_accessor :n

    # ExifTool option +-sort+ Sort output alphabetically
    attr_accessor :sort

    # ExifTool option +-e+ (+--composite+) Do not generate composite tags
    attr_accessor :e

    # ExifTool option +-ee[NUM]+ (+-extractEmbedded+) Extract information from embedded files
    attr_accessor :ee

    # ExifTool option +-F[OFFSET]+ (+-fixBase+) Fix the base for maker notes offsets
    attr_accessor :F

    # ExifTool option +-fast[NUM]+ Increase speed when extracting metadata
    attr_accessor :fast

    # ExifTool option +-m+ (+-ignoreMinorErrors+) Ignore minor errors and warnings
    attr_accessor :m

    # ExifTool option <code>-o OUTFILE</code> (+-out+) Set output file or directory name
    attr_accessor :o

    # ExifTool option <code>-password PASSWD</code> Password for processing protected files
    attr_accessor :password

    # ExifTool option <code>-globalTimeShift SHIFT</code> Shift all formatted date/time values
    attr_accessor :globaltimeshift

    # ExifTool option <code>-config CFGFILE</code> Specify configuration file name
    attr_accessor :config

    # ExifTool option +-overwrite_original+ Overwrite original by renaming tmp file
    attr_accessor :overwrite_original

    # ExifTool option +-overwrite_original_in_place+ Overwrite original by copying tmp file
    attr_accessor :overwrite_original_in_place

    # ExifTool option +-P+ (+-preserve+) Preserve file modification date/time
    attr_accessor :P

    # ExifTool option <code>-geotag TRKFILE</code> Geotag images from specified GPS log
    attr_accessor :geotag

    alias :binary :b
    alias :binary= :b= # :nodoc:
    alias :coordformat :c
    alias :coordformat= :c= # :nodoc:
    alias :groupheadings :g
    alias :groupheadings= :g= # :nodoc:
    alias :group :g
    alias :group= :g= # :nodoc:
    alias :noprintconv :n
    alias :noprintconv= :n= # :nodoc:
    alias :numerical :n
    alias :numerical= :n= # :nodoc:
    alias :nocomposite :e
    alias :nocomposite= :e= # :nodoc:
    alias :extractembedded :ee
    alias :extractembedded= :ee= # :nodoc:
    alias :fixbase :F
    alias :fixbase= :F= # :nodoc:
    alias :ignoreminorerrors :m
    alias :ignoreminorerrors= :m= # :nodoc:
    alias :out :o
    alias :out= :o= # :nodoc:
    alias :preserve :P
    alias :preserve= :P= # :nodoc:

    undef p

    def initialize values={}
      values.each_pair do |k, v|
        self.send "#{k}=", v
      end
    end

    def [] opt
      self.send(opt)
    end

    def []= opt, val
      self.send("#{opt}=", val)
    end

    def merge other
      Options.new(self.to_h.merge(other.to_h))
    end

    def to_h
      res = {}
      self.instance_variables.sort.each do |var|
        val = instance_variable_get var
        unless val.nil?
          res[var.to_s.sub(/^@/, '').to_sym] = val
        end
      end
      res
    end

    alias to_hash to_h

    # Gets an array of the command-line arguments for this instance (internal
    # use)
    def options_args
      args = []
      to_h.each_pair do |k, v|
        case k.to_s
        when /^(.+)_charset$/
          args << ['-charset', "#{$1}=#{v}"]
        when 'g', 'ee', 'F', 'fast'
          args << "-#{k}#{v}"
        else
          case v
          when true
            args << "-#{k}"
          when nil, false
          else
            args << ["-#{k}", v]
          end
        end
      end
      args.flatten.map(&:to_s)
    end

    def == other
      to_h == other.to_h
    end

    private

    def method_missing meth, *args
      m = try_find_real_method_name(meth)
      if m
        return self.send(m, *args)
      end
      opt = meth.to_s.sub(/=$/, '')
      raise Error.new("option #{opt} is not supported")
    end

    def respond_to_missing? meth, *args
      !try_find_real_method_name(meth).nil?
    end


    def try_find_real_method_name meth
      m = +meth.to_s
      if m =~ /^[a-zA-Z]=?$/
        return nil
      end
      if m =~ /[A-Z]/
        m.downcase!
        if self.respond_to?(m)
          return m
        end
      end
      if m =~ /^[a-z]+(?:_[a-z0-9]+)+/
        m.gsub!('_', '')
        if self.respond_to? m
          return m
        end
      end
      nil
    end

  end

end
