require "isbn_utils/registration_group_ranges"
require "isbn_utils/registrant_ranges"


module ISBNUtils
  module ISBN13

    extend self

    def valid?(isbn)
      correct_format?(isbn) && isbn[-1] == calc_check_digit(isbn)
    end

    def correct_format?(isbn)
      isbn = isbn.delete("-")
      !!(/\A97[89]\d{9}\d\z/ =~ isbn)
    end

    def calc_check_digit(isbn)
      nums = isbn.delete("-").split("")[0..11].map{|x| x.to_i }
      sum = nums.zip([1, 3] * 6).map{|x, y| x * y }.inject(:+)
      check_digit = 10 - (sum % 10)
      check_digit == 10 ? "0" : check_digit.to_s
    end

    def hyphenate(isbn)
      ean_prefix = isbn[0..2]
      body = isbn[3..11]
      check_digit = isbn[12..12]
      registration_group, body = split_to_parts(body, ean_prefix, ISBNUtils::RegistrationGroupRanges)
      prefix = "#{ean_prefix}-#{registration_group}"
      registrant, publication = split_to_parts(body, prefix, ISBNUtils::RegistrantRanges)
      [ean_prefix, registration_group, registrant, publication, check_digit].join("-")
    end

    def split_to_parts(body, prefix, ranges)
      g = ""
      ranges[prefix].each do |range_str|
        s, e = range_str.split("-")
        g = body[0..(s.size - 1)]
        break if Range.new(s.to_i, e.to_i).cover?(g.to_i)
      end
      [g, body[(g.size)..]]
    end

  end
end
