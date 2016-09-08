require 'rspec/matchers'
require 'howitzer/exceptions'

module Howitzer
  # This class describes single email
  class Email
    include ::RSpec::Matchers

    attr_reader :message

    # @return [<MailAdapters::Abstract>] mail adapter class

    def self.adapter
      return @adapter if @adapter
      self.adapter = Howitzer.mail_adapter.to_sym
      @adapter
    end

    class << self
      attr_reader :adapter_name

      protected

      def subject(value)
        @subject = value
      end
    end

    # Specifies a mail adapter
    # @param adapter_name [String, Symbol] email adapter name
    # @raise NoMailAdapterError when adapter name is not String or Symbol

    def self.adapter=(adapter_name)
      @adapter_name = adapter_name
      case adapter_name
        when Symbol, String
          require "howitzer/mail_adapters/#{adapter_name}"
          @adapter = MailAdapters.const_get(adapter_name.to_s.capitalize.to_s)
        else
          raise NoMailAdapterError
      end
    end

    # Searches a mail by a recepient
    # @param recepient [String] recepient's email address
    # @param params [Hash] placeholders with appropriate values
    # @raise NoEmailSubjectError when subject is not specified for email class
    # @return [Email] instance of email message

    def self.find_by_recipient(recipient, params = {})
      raise NoEmailSubjectError, "Please specify email subject. For example:\n" \
                                  "class SomeEmail < Howitzer::Email\n" \
                                  "  subject ‘some subject text’\nend" if @subject.nil?
      new(adapter.find(recipient, expand_subject(params)))
    end

    def initialize(message)
      @message = message
    end

    # @return [String, nil] plain text of email message

    def plain_text_body
      message.plain_text_body
    end

    # @return [String, nil] html body of email message

    def html_body
      message.html_body
    end

    # @return [String, nil] mail text

    def text
      message.text
    end

    # @return [String] who has send email data in format: User Name <user@email>

    def mail_from
      message.mail_from
    end

    # @return [Array<String>] array of recipients who has received current email

    def recipients
      message.recipients
    end

    # @return [String] email received time

    def received_time
      message.received_time
    end

    # @return [String] sender user email

    def sender_email
      message.sender_email
    end

    # Allows to get email MIME attachment

    def mime_part
      message.mime_part
    end

    def self.expand_subject(params)
      params.each { |k, v| @subject.sub!(":#{k}", v.to_s) }
      @subject
    end
    private_class_method :expand_subject
  end
end
