# encoding: utf-8
# frozen_string_literal: true

module MultiExiftool

  # Represents messages of different types of the execution of ExifTool calls
  class Messages

    attr_reader :all, :errors, :infos, :warnings

    def initialize messages
      @all = messages
    end

    def errors
      @errors ||= @all.select {|m| m =~ /^Error: /}
    end

    def infos
      @infos ||= @all.reject {|m| m =~ /^(Error|Warning): /}
    end

    def warnings
      @warnings ||= @all.select {|m| m =~ /^Warning: /}
    end

    def errors_and_warnings
      @errors_and_warnings ||= @all.select {|m| m =~ /^(Error|Warning): /}
    end

    alias warnings_and_errors errors_and_warnings

    def deconstruct_keys keys
      if keys.nil?
        return deconstruct_keys(%i(all errors infos warnings errors_and_warnings warnings_and_errors))
      end
      res = {}
      keys.each do |k|
        if self.respond_to? k
          res[k] = self.send(k)
        else
          return {}
        end
      end
      return res
    end

    def errors?
      !errors.empty?
    end

    def infos?
      !infos.empty?
    end

    def warnings?
      !warnings.empty?
    end

    def errors_or_warnings?
      !errors_and_warnings.empty?
    end

    alias warnings_or_errors? errors_or_warnings?

  end


end
