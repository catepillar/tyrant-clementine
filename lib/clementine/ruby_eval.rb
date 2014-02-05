class RubyEval
  include Cinch::Plugin

  match /(.*)$/i, prefix: '>>', method: :execute #, react_on: :channel


  def execute(msg, query)
	return unless msg.user.authname == "catepillar"
    msg.reply "#{eval query}"
  end
end