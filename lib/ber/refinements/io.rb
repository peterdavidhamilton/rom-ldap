module BER
  refine ::IO do
    def read_ber(syntax = nil)
      BER.function.read_ber(self, syntax)
    end

    def read_ber_length
      BER.function.read_ber_length(self)
    end

    def parse_ber_object(syntax, id, data)
      BER.function.parse_ber_object(self, syntax, id, data)
    end

    # def read_ber(syntax = nil)
    #   rule_logic.read_ber(syntax)
    # end

    # def read_ber_length
    #   rule_logic.read_ber_length
    # end

    # def parse_ber_object(syntax, id, data)
    #   rule_logic.parse_ber_object(syntax, id, data)
    # end

    # def rule_logic
    #   @rule_logic ||= RuleLogic.new(self)
    # end

  end
end
