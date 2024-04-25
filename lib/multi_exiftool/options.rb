# encoding: utf-8
# frozen_string_literal: true

module MultiExiftool

  # Represents option for the ExifTool command-line application
  class Options

    # ExifTool option +-b+ (+-binary+) Output metadata in binary format
    attr_accessor :b

    # ExifTool option +-c FMT (+-coordFormat+) Set format for GPS coordinates
    attr_accessor :c

    # ExifTool option +-charset exif=CHARSET+ Specify encoding for special characters
    attr_accessor :exif_charset

    # ExifTool option +-charset id3=CHARSET+ Specify encoding for special characters
    attr_accessor :id3_charset

    # ExifTool option +-charset iptc=CHARSET+ Specify encoding for special characters
    attr_accessor :iptc_charset

    # ExifTool option +-charset photoshop=CHARSET+ Specify encoding for special characters
    attr_accessor :photoshop_charset

    # ExifTool option +-charset quicktime=CHARSET+ Specify encoding for special characters
    attr_accessor :quicktime_charset

    # ExifTool option +-charset riff=CHARSET+ Specify encoding for special characters
    attr_accessor :riff_charset

    # Exiftool option +-g[NUM...]+ (+-groupHeadings+) Organize output by tag group
    attr_accessor :g

    # ExifTool option +-lang [LANG]+ Set current language
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

    # ExifTool option +-password PASSWD+ Password for processing protected files
    attr_accessor :password

    # ExifTool option +-globalTimeShift SHIFT+ Shift all formatted date/time values
    attr_accessor :globaltimeshift

    # ExifTool option +-config CFGFILE+ Specify configuration file name
    attr_accessor :config


    # ExifTool option +-overwrite_original+ Overwrite original by renaming tmp file
    attr_accessor :overwrite_original

    # ExifTool option +-overwrite_original_in_place+ Overwrite original by copying tmp file
    attr_accessor :overwrite_original_in_place

    # ExifTool option +-P+ (+-preserve+) Preserve file modification date/time
    attr_accessor :P

    # ExifTool option +-geotag TRKFILE+ Geotag images from specified GPS log
    attr_accessor :geotag

    alias :binary :b
    alias :binary= :b=
    alias :coordformat :c
    alias :coordformat= :c=
    alias :groupheadings :g
    alias :groupheadings= :g=
    alias :group :g
    alias :group= :g=
    alias :noprintconv :n
    alias :noprintconv= :n=
    alias :numerical :n
    alias :numerical= :n=
    alias :nocomposite :e
    alias :nocomposite= :e=
    alias :extractembedded :ee
    alias :extractembedded= :ee=
    alias :fixbase :F
    alias :fixbase= :F=
    alias :ignoreminorerrors :m
    alias :ignoreminorerrors= :m=
    alias :preserve :P
    alias :preserve= :P=

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
      m = meth.to_s
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
