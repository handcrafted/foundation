# $Id: saikuro 33 2006-12-07 16:09:55Z zev $
# Version 0.2
# == Usage
#
# ruby saikuro.rb [ -h ] [-o output_directory] [-f type] [ -c, -t ]
# [ -y, -w, -e, -k, -s, -d - number ] ( -p file | -i directory )
#
# == Help
#
# -o, --output_directory (directory) : A directory to ouput the results in.
# The current directory is used if this option is not passed.
#
# -h, --help : This help message.
#
# -f, --formater (html | text) : The format to output the results in.
# The default is html
#
# -c, --cyclo : Compute the cyclomatic complexity of the input.
#
# -t, --token : Count the number of tokens per line of the input.
#
# -y, --filter_cyclo (number) : Filter the output to only include methods
# whose cyclomatic complexity are greater than the passed number.
#
# -w, --warn_cyclo (number) : Highlight with a warning methods whose
# cyclomatic complexity are greather than or equal to the passed number.
#
#
# -e, --error_cyclo (number) : Highligh with an error methods whose
# cyclomatic complexity are greather than or equal to the passed number.
#
#
# -k, --filter_token (number) : Filter the output to only include lines
# whose token count are greater than the passed number.
#
#
# -s, --warn_token (number) : Highlight with a warning lines whose
# token count are greater than or equal to the passed number.
#
#
# -d, --error_token (number) : Highlight with an error lines whose
# token count are greater than or equal to the passed number.
#
#
# -p, --parse_file (file) : A file to use as input.
#
# -i, --input_directory (directory) : All ruby files found recursively
# inside the directory are passed as input.

# == License
# Saikruo uses the BSD license.
#
# Copyright (c) 2005, Ubiquitous Business Technology (http://ubit.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#
#    * Neither the name of Ubiquitous Business Technology nor the names
#      of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written
#      permission.
#
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# == Author
# Zev Blut (zb@ubit.com)

require 'irb/ruby-lex'
require 'yaml'

# States to watch for
# once in def get the token after space, because it may also
# be something like + or << for operator overloading.

# Counts the number of tokens in each line.
class TokenCounter
  include RubyToken

  attr_reader :current_file

  def initialize
    @files = Hash.new
    @tokens_per_line = Hash.new(0)
    @current_file = ""
  end

  # Mark file to associate with the token count.
  def set_current_file(file)
    @current_file = file
    @tokens_per_line = Hash.new(0)
    @files[@current_file] = @tokens_per_line
  end

  # Iterate through all tracked files, passing the
  # the provided formater the token counts.
  def list_tokens_per_line(formater)
    formater.start_count(@files.size)
    @files.each do |fname, tok_per_line|
      formater.start_file(fname)
      tok_per_line.sort.each do |line,num|
	formater.line_token_count(line,num)
      end
      formater.end_file
    end
  end

  # Count the token for the passed line.
  def count_token(line_no,token)
    case token
    when TkSPACE, TkNL, TkRD_COMMENT
      # Do not count these as tokens
    when TkCOMMENT
      # Ignore this only for comments in a statement?
      # Ignore TkCOLON,TkCOLON2  and operators? like "." etc..
    when TkRBRACK, TkRPAREN, TkRBRACE
      # Ignore the closing of an array/index/hash/paren
      # The opening is counted, but no more.
      # Thus [], () {} is counted as 1 token not 2.
    else
      # may want to filter out comments...
      @tokens_per_line[line_no] += 1
    end
  end

end

# Main class and structure used to compute the
# cyclomatic complexity of Ruby programs.
class ParseState
  include RubyToken
  attr_accessor :name, :children, :complexity, :parent, :lines

  @@top_state = nil
  def ParseState.make_top_state()
    @@top_state = ParseState.new(nil)
    @@top_state.name = "__top__"
    @@top_state
  end

  @@token_counter = TokenCounter.new
  def ParseState.set_token_counter(counter)
    @@token_counter = counter
  end
  def ParseState.get_token_counter
    @@token_counter
  end

  def initialize(lexer,parent=nil)
    @name = ""
    @children = Array.new
    @complexity = 0
    @parent = parent
    @lexer = lexer
    @run = true
    # To catch one line def statements, We always have one line.
    @lines = 0
    @last_token_line_and_char = Array.new
  end

  def top_state?
    self == @@top_state
  end

  def lexer=(lexer)
    @run = true
    @lexer = lexer
  end

  def make_state(type,parent = nil)
    cstate = type.new(@lexer,self)
    parent.children<< cstate
    cstate
  end

  def calc_complexity
    complexity = @complexity
    children.each do |child|
      complexity += child.calc_complexity
    end
    complexity
  end

  def calc_lines
    lines = @lines
    children.each do |child|
      lines += child.calc_lines
    end
    lines
  end

  def compute_state(formater)
    if top_state?
      compute_state_for_global(formater)
    end

    @children.each do |s|
      s.compute_state(formater)
    end
  end

  def compute_state_for_global(formater)
    global_def, @children = @children.partition do |s|
      !s.kind_of?(ParseClass)
    end
    return if global_def.empty?
    gx = global_def.inject(0) { |c,s| s.calc_complexity }
    gl = global_def.inject(0) { |c,s| s.calc_lines }
    formater.start_class_compute_state("Global", "", gx, gl)
    global_def.each do |s|
      s.compute_state(formater)
    end
    formater.end_class_compute_state("")
  end

  # Count the tokens parsed if true else ignore them.
  def count_tokens?
    true
  end

  def parse
    while @run do
      tok = @lexer.token
      @run = false if tok.nil?
      if lexer_loop?(tok)
        STDERR.puts "Lexer loop at line : #{@lexer.line_no} char #{@lexer.char_no}."
        @run = false
      end
      @last_token_line_and_char<< [@lexer.line_no.to_i, @lexer.char_no.to_i, tok]
      if $VERBOSE
	puts "DEBUG: #{@lexer.line_no} #{tok.class}:#{tok.name if tok.respond_to?(:name)}"
      end
      @@token_counter.count_token(@lexer.line_no, tok) if count_tokens?
      parse_token(tok)
    end
  end

  # Ruby-Lexer can go into a loop if the file does not end with a newline.
  def lexer_loop?(token)
    return false if @last_token_line_and_char.empty?
    loop_flag = false
    last = @last_token_line_and_char.last
    line = last[0]
    char = last[1]
    ltok = last[2]

    if ( (line == @lexer.line_no.to_i) &&
           (char == @lexer.char_no.to_i) &&
           (ltok.class == token.class) )
      # We are potentially in a loop
      if @last_token_line_and_char.size >= 3
        loop_flag = true
      end
    else
      # Not in a loop so clear stack
      @last_token_line_and_char = Array.new
    end

    loop_flag
  end

  def do_begin_token(token)
    make_state(EndableParseState, self)
  end

  def do_class_token(token)
    make_state(ParseClass,self)
  end

  def do_module_token(token)
    make_state(ParseModule,self)
  end

  def do_def_token(token)
    make_state(ParseDef,self)
  end

  def do_constant_token(token)
    nil
  end

  def do_identifier_token(token)
    if (token.name == "__END__" && token.char_no.to_i == 0)
      # The Ruby code has stopped and the rest is data so cease parsing.
      @run = false
    end
    nil
  end

  def do_right_brace_token(token)
    nil
  end

  def do_end_token(token)
    end_debug
    nil
  end

  def do_block_token(token)
    make_state(ParseBlock,self)
  end

  def do_conditional_token(token)
    make_state(ParseCond,self)
  end

  def do_conditional_do_control_token(token)
    make_state(ParseDoCond,self)
  end

  def do_case_token(token)
    make_state(EndableParseState, self)
  end

  def do_one_line_conditional_token(token)
    # This is an if with no end
    @complexity += 1
    #STDOUT.puts "got IF_MOD: #{self.to_yaml}" if $VERBOSE
    #if state.type != "class" && state.type != "def" && state.type != "cond"
    #STDOUT.puts "Changing IF_MOD Parent" if $VERBOSE
    #state = state.parent
    #@run = false
    nil
  end

  def do_else_token(token)
    STDOUT.puts "Ignored/Unknown Token:#{token.class}" if $VERBOSE
    nil
  end

  def do_comment_token(token)
    make_state(ParseComment, self)
  end

  def do_symbol_token(token)
    make_state(ParseSymbol, self)
  end

  def parse_token(token)
    state = nil
    case token
    when TkCLASS
      state = do_class_token(token)
    when TkMODULE
      state = do_module_token(token)
    when TkDEF
      state = do_def_token(token)
    when TkCONSTANT
      # Nothing to do with a constant at top level?
      state = do_constant_token(token)
    when TkIDENTIFIER,TkFID
      # Nothing to do at top level?
      state = do_identifier_token(token)
    when TkRBRACE
      # Nothing to do at top level
      state = do_right_brace_token(token)
    when TkEND
      state = do_end_token(token)
      # At top level this might be an error...
    when TkDO,TkfLBRACE
      state = do_block_token(token)
    when TkIF,TkUNLESS
      state = do_conditional_token(token)
    when TkWHILE,TkUNTIL,TkFOR
      state = do_conditional_do_control_token(token)
    when TkELSIF #,TkELSE
      @complexity += 1
    when TkELSE
      # Else does not increase complexity
    when TkCASE
      state = do_case_token(token)
    when TkWHEN
      @complexity += 1
    when TkBEGIN
      state = do_begin_token(token)
    when TkRESCUE
      # Maybe this should add complexity and not begin
      @complexity += 1
    when TkIF_MOD, TkUNLESS_MOD, TkUNTIL_MOD, TkWHILE_MOD, TkQUESTION
      state = do_one_line_conditional_token(token)
    when TkNL
      #
      @lines += 1
    when TkRETURN
      # Early returns do not increase complexity as the condition that
      # calls the return is the one that increases it.
    when TkCOMMENT
      state = do_comment_token(token)
    when TkSYMBEG
      state = do_symbol_token(token)
    when TkError
      STDOUT.puts "Lexer received an error for line #{@lexer.line_no} char #{@lexer.char_no}"
    else
      state = do_else_token(token)
    end
    state.parse if state
  end

  def end_debug
    STDOUT.puts "got an end: #{@name} in #{self.class.name}" if $VERBOSE
    if @parent.nil?
      STDOUT.puts "DEBUG: Line #{@lexer.line_no}"
      STDOUT.puts "DEBUG: #{@name}; #{self.class}"
      # to_yaml can cause an infinite loop?
      #STDOUT.puts "TOP: #{@@top_state.to_yaml}"
      #STDOUT.puts "TOP: #{@@top_state.inspect}"

      # This may not be an error?
      #exit 1
    end
  end

end

# Read and consume tokens in comments until a new line.
class ParseComment < ParseState

  # While in a comment state do not count the tokens.
  def count_tokens?
    false
  end

  def parse_token(token)
    if token.is_a?(TkNL)
      @lines += 1
      @run = false
    end
  end
end

class ParseSymbol < ParseState
  def initialize(lexer, parent = nil)
    super
    STDOUT.puts "STARTING SYMBOL" if $VERBOSE
  end

  def parse_token(token)
    STDOUT.puts "Symbol's token is #{token.class}" if $VERBOSE
    # Consume the next token and stop
    @run = false
    nil
  end
end

class EndableParseState < ParseState
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    STDOUT.puts "Starting #{self.class}" if $VERBOSE
  end

  def do_end_token(token)
    end_debug
    @run = false
    nil
  end
end

class ParseClass < EndableParseState
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @type_name = "Class"
  end

  def do_constant_token(token)
    @name = token.name if @name.empty?
    nil
  end

  def compute_state(formater)
    # Seperate the Module and Class Children out
    cnm_children, @children = @children.partition do |child|
      child.kind_of?(ParseClass)
    end

    formater.start_class_compute_state(@type_name,@name,self.calc_complexity,self.calc_lines)
    super(formater)
    formater.end_class_compute_state(@name)

    cnm_children.each do |child|
      child.name = @name + "::" + child.name
      child.compute_state(formater)
    end
  end
end

class ParseModule < ParseClass
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @type_name = "Module"
  end
end

class ParseDef < EndableParseState

  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @complexity = 1
    @looking_for_name = true
    @first_space = true
  end

  # This way I don't need to list all possible overload
  # tokens.
  def create_def_name(token)
    case token
    when TkSPACE
      # mark first space so we can stop at next space
      if @first_space
	@first_space = false
      else
	@looking_for_name = false
      end
    when TkNL,TkLPAREN,TkfLPAREN,TkSEMICOLON
      # we can also stop at a new line or left parenthesis
      @looking_for_name = false
    when TkDOT
      @name<< "."
    when TkCOLON2
      @name<< "::"
    when TkASSIGN
      @name<< "="
    when TkfLBRACK
      @name<< "["
    when TkRBRACK
      @name<< "]"
    else
      begin
	@name<< token.name.to_s
      rescue Exception => err
	#what is this?
	STDOUT.puts @@token_counter.current_file
	STDOUT.puts @name
	STDOUT.puts token.inspect
	STDOUT.puts err.message
	exit 1
      end
    end
  end

  def parse_token(token)
    if @looking_for_name
      create_def_name(token)
    end
    super(token)
  end

  def compute_state(formater)
    formater.def_compute_state(@name, self.calc_complexity, self.calc_lines)
    super(formater)
  end
end

class ParseCond < EndableParseState
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @complexity = 1
  end
end

class ParseDoCond < ParseCond
  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @looking_for_new_line = true
  end

  # Need to consume the do that can appear at the
  # end of these control structures.
  def parse_token(token)
    if @looking_for_new_line
      if token.is_a?(TkDO)
        nil
      else
        if token.is_a?(TkNL)
          @looking_for_new_line = false
        end
        super(token)
      end
    else
      super(token)
    end
  end

end

class ParseBlock < EndableParseState

  def initialize(lexer,parent=nil)
    super(lexer,parent)
    @complexity = 1
    @lbraces = Array.new
  end

  # Because the token for a block and hash right brace is the same,
  # we need to track the hash left braces to determine when an end is
  # encountered.
  def parse_token(token)
    if token.is_a?(TkLBRACE)
      @lbraces.push(true)
    elsif token.is_a?(TkRBRACE)
      if @lbraces.empty?
        do_right_brace_token(token)
        #do_end_token(token)
      else
        @lbraces.pop
      end
    else
      super(token)
    end
  end

  def do_right_brace_token(token)
    # we are done ? what about a hash in a block :-/
    @run = false
    nil
  end

end

# ------------ END Analyzer logic ------------------------------------

class Filter
  attr_accessor :limit, :error, :warn

  def initialize(limit = -1, error = 11, warn = 8)
    @limit = limit
    @error = error
    @warn = warn
  end

  def ignore?(count)
    count < @limit
  end

  def warn?(count)
    count >= @warn
  end

  def error?(count)
    count >= @error
  end

end


class BaseFormater
  attr_accessor :warnings, :errors, :current

  def initialize(out, filter = nil)
    @out = out
    @filter = filter
    reset_data
  end

  def warn_error?(num, marker)
    klass = ""

    if @filter.error?(num)
      klass = ' class="error"'
      @errors<< [@current, marker, num]
    elsif @filter.warn?(num)
      klass = ' class="warning"'
      @warnings<< [@current, marker, num]
    end

    klass
  end

  def reset_data
    @warnings = Array.new
    @errors = Array.new
    @current = ""
  end

end

class TokenCounterFormater < BaseFormater

  def start(new_out=nil)
    reset_data
    @out = new_out if new_out
    @out.puts "Token Count"
  end

  def start_count(number_of_files)
    @out.puts "Counting tokens for #{number_of_files} files."
  end

  def start_file(file_name)
    @current = file_name
    @out.puts "File:#{file_name}"
  end

  def line_token_count(line_number,number_of_tokens)
    return if @filter.ignore?(number_of_tokens)
    warn_error?(number_of_tokens, line_number)
    @out.puts "Line:#{line_number} ; Tokens : #{number_of_tokens}"
  end

  def end_file
    @out.puts ""
  end

  def end_count
  end

  def end
  end

end

module HTMLStyleSheet
  def HTMLStyleSheet.style_sheet
    out = StringIO.new

    out.puts "<style>"
    out.puts 'body {'
    out.puts '	margin: 20px;'
    out.puts '	padding: 0;'
    out.puts '	font-size: 12px;'
    out.puts '	font-family: bitstream vera sans, verdana, arial, sans serif;'
    out.puts '	background-color: #efefef;'
    out.puts '}'
    out.puts ''
    out.puts 'table {	'
    out.puts '	border-collapse: collapse;'
    out.puts '	/*border-spacing: 0;*/'
    out.puts '	border: 1px solid #666;'
    out.puts '	background-color: #fff;'
    out.puts '	margin-bottom: 20px;'
    out.puts '}'
    out.puts ''
    out.puts 'table, th, th+th, td, td+td  {'
    out.puts '	border: 1px solid #ccc;'
    out.puts '}'
    out.puts ''
    out.puts 'table th {'
    out.puts '	font-size: 12px;'
    out.puts '	color: #fc0;'
    out.puts '	padding: 4px 0;'
    out.puts '	background-color: #336;'
    out.puts '}'
    out.puts ''
    out.puts 'th, td {'
    out.puts '	padding: 4px 10px;'
    out.puts '}'
    out.puts ''
    out.puts 'td {	'
    out.puts '	font-size: 13px;'
    out.puts '}'
    out.puts ''
    out.puts '.class_name {'
    out.puts '	font-size: 17px;'
    out.puts '	margin: 20px 0 0;'
    out.puts '}'
    out.puts ''
    out.puts '.class_complexity {'
    out.puts 'margin: 0 auto;'
    out.puts '}'
    out.puts ''
    out.puts '.class_complexity>.class_complexity {'
    out.puts '	margin: 0;'
    out.puts '}'
    out.puts ''
    out.puts '.class_total_complexity, .class_total_lines, .start_token_count, .file_count {'
    out.puts '	font-size: 13px;'
    out.puts '	font-weight: bold;'
    out.puts '}'
    out.puts ''
    out.puts '.class_total_complexity, .class_total_lines {'
    out.puts '	color: #c00;'
    out.puts '}'
    out.puts ''
    out.puts '.start_token_count, .file_count {'
    out.puts '	color: #333;'
    out.puts '}'
    out.puts ''
    out.puts '.warning {'
    out.puts '	background-color: yellow;'
    out.puts '}'
    out.puts ''
    out.puts '.error {'
    out.puts '	background-color: #f00;'
    out.puts '}'
    out.puts "</style>"

    out.string
  end

  def style_sheet
    HTMLStyleSheet.style_sheet
  end
end


class HTMLTokenCounterFormater < TokenCounterFormater
  include HTMLStyleSheet

  def start(new_out=nil)
    reset_data
    @out = new_out if new_out
    @out.puts "<html>"
    @out.puts style_sheet
    @out.puts "<body>"
  end

  def start_count(number_of_files)
    @out.puts "<div class=\"start_token_count\">"
    @out.puts "Number of files: #{number_of_files}"
    @out.puts "</div>"
  end

  def start_file(file_name)
    @current = file_name
    @out.puts "<div class=\"file_count\">"
    @out.puts "<p class=\"file_name\">"
    @out.puts "File: #{file_name}"
    @out.puts "</p>"
    @out.puts "<table width=\"100%\" border=\"1\">"
    @out.puts "<tr><th>Line</th><th>Tokens</th></tr>"
  end

  def line_token_count(line_number,number_of_tokens)
    return if @filter.ignore?(number_of_tokens)
    klass = warn_error?(number_of_tokens, line_number)
    @out.puts "<tr><td>#{line_number}</td><td#{klass}>#{number_of_tokens}</td></tr>"
  end

  def end_file
    @out.puts "</table>"
  end

  def end_count
  end

  def end
    @out.puts "</body>"
    @out.puts "</html>"
  end
end

class ParseStateFormater < BaseFormater

  def start(new_out=nil)
    reset_data
    @out = new_out if new_out
  end

  def end
  end

  def start_class_compute_state(type_name,name,complexity,lines)
    @current = name
    @out.puts "-- START #{name} --"
    @out.puts "Type:#{type_name} Name:#{name} Complexity:#{complexity} Lines:#{lines}"
  end

  def end_class_compute_state(name)
    @out.puts "-- END #{name} --"
  end

  def def_compute_state(name,complexity,lines)
    return if @filter.ignore?(complexity)
    warn_error?(complexity, name)
    @out.puts "Type:Def Name:#{name} Complexity:#{complexity} Lines:#{lines}"
  end

end



class StateHTMLComplexityFormater < ParseStateFormater
  include HTMLStyleSheet

  def start(new_out=nil)
    reset_data
    @out = new_out if new_out
    @out.puts "<html><head><title>Cyclometric Complexity</title></head>"
    @out.puts style_sheet
    @out.puts "<body>"
  end

  def end
    @out.puts "</body>"
    @out.puts "</html>"
  end

  def start_class_compute_state(type_name,name,complexity,lines)
    @current = name
    @out.puts "<div class=\"class_complexity\">"
    @out.puts "<h2 class=\"class_name\">#{type_name} : #{name}</h2>"
    @out.puts "<div class=\"class_total_complexity\">Total Complexity: #{complexity}</div>"
    @out.puts "<div class=\"class_total_lines\">Total Lines: #{lines}</div>"
    @out.puts "<table width=\"100%\" border=\"1\">"
    @out.puts "<tr><th>Method</th><th>Complexity</th><th># Lines</th></tr>"
  end

  def end_class_compute_state(name)
    @out.puts "</table>"
    @out.puts "</div>"
  end

  def def_compute_state(name, complexity, lines)
    return if @filter.ignore?(complexity)
    klass = warn_error?(complexity, name)
    @out.puts "<tr><td>#{name}</td><td#{klass}>#{complexity}</td><td>#{lines}</td></tr>"
  end

end


module ResultIndexGenerator
  def summarize_errors_and_warnings(enw, header)
    return "" if enw.empty?
    f = StringIO.new
    erval = Hash.new { |h,k| h[k] = Array.new }
    wval = Hash.new { |h,k| h[k] = Array.new }

    enw.each do |fname, warnings, errors|
      errors.each do |c,m,v|
        erval[v] << [fname, c, m]
      end
      warnings.each do |c,m,v|
        wval[v] << [fname, c, m]
      end
    end

    f.puts "<h2 class=\"class_name\">Errors and Warnings</h2>"
    f.puts "<table width=\"100%\" border=\"1\">"
    f.puts header

    f.puts print_summary_table_rows(erval, "error")
    f.puts print_summary_table_rows(wval, "warning")
    f.puts "</table>"

    f.string
  end

  def print_summary_table_rows(ewvals, klass_type)
    f = StringIO.new
    ewvals.sort { |a,b| b <=> a}.each do |v, vals|
      vals.sort.each do |fname, c, m|
        f.puts "<tr><td><a href=\"./#{fname}\">#{c}</a></td><td>#{m}</td>"
        f.puts "<td class=\"#{klass_type}\">#{v}</td></tr>"
      end
    end
    f.string
  end

  def list_analyzed_files(files)
    f = StringIO.new
    f.puts "<h2 class=\"class_name\">Analyzed Files</h2>"
    f.puts "<ul>"
    files.each do |fname, warnings, errors|
      readname = fname.split("_")[0...-1].join("_")
      f.puts "<li>"
      f.puts "<p class=\"file_name\"><a href=\"./#{fname}\">#{readname}</a>"
      f.puts "</li>"
    end
    f.puts "</ul>"
    f.string
  end

  def write_index(files, filename, title, header)
    return if files.empty?

    File.open(filename,"w") do |f|
      f.puts "<html><head><title>#{title}</title></head>"
      f.puts "#{HTMLStyleSheet.style_sheet}\n<body>"
      f.puts "<h1>#{title}</h1>"

      enw = files.find_all { |fn,w,e| (!w.empty? || !e.empty?) }

      f.puts summarize_errors_and_warnings(enw, header)

      f.puts "<hr/>"
      f.puts list_analyzed_files(files)
      f.puts "</body></html>"
    end
  end

  def write_cyclo_index(files, output_dir)
    header = "<tr><th>Class</th><th>Method</th><th>Complexity</th></tr>"
    write_index(files,
                "#{output_dir}/index_cyclo.html",
                "Index for cyclomatic complexity",
                header)
  end

  def write_token_index(files, output_dir)
    header = "<tr><th>File</th><th>Line #</th><th>Tokens</th></tr>"
    write_index(files,
                "#{output_dir}/index_token.html",
                "Index for tokens per line",
                header)
  end

end

module Saikuro
  def Saikuro.analyze(files, state_formater, token_count_formater, output_dir)

    idx_states = Array.new
    idx_tokens = Array.new

    # parse each file
    files.each do |file|
      begin
        STDOUT.puts "Parsing #{file}"
        # create top state
        top = ParseState.make_top_state
        STDOUT.puts "TOP State made" if $VERBOSE
        token_counter = TokenCounter.new
        ParseState.set_token_counter(token_counter)
        token_counter.set_current_file(file)

        STDOUT.puts "Setting up Lexer" if $VERBOSE
        lexer = RubyLex.new
        # Turn of this, because it aborts when a syntax error is found...
        lexer.exception_on_syntax_error = false
        lexer.set_input(File.new(file,"r"))
        top.lexer = lexer
        STDOUT.puts "Parsing" if $VERBOSE
        top.parse


        fdir_path = seperate_file_from_path(file)
        FileUtils.makedirs("#{output_dir}/#{fdir_path}")

        if state_formater
          # output results
          state_io = StringIO.new
          state_formater.start(state_io)
          top.compute_state(state_formater)
          state_formater.end

          fname = "#{file}_cyclo.html"
          puts "writing cyclomatic #{file}" if $VERBOSE
          File.open("#{output_dir}/#{fname}","w") do |f|
            f.write state_io.string
          end
          idx_states<< [
            fname,
            state_formater.warnings.dup,
            state_formater.errors.dup,
          ]
        end

        if token_count_formater
          token_io = StringIO.new
          token_count_formater.start(token_io)
          token_counter.list_tokens_per_line(token_count_formater)
          token_count_formater.end

          fname = "#{file}_token.html"
          puts "writing token #{file}" if $VERBOSE
          File.open("#{output_dir}/#{fname}","w") do |f|
            f.write token_io.string
          end
          idx_tokens<< [
            fname,
            token_count_formater.warnings.dup,
            token_count_formater.errors.dup,
          ]
        end

      rescue RubyLex::SyntaxError => synerr
        STDOUT.puts "Lexer error for file #{file} on line #{lexer.line_no}"
        STDOUT.puts "#{synerr.class.name} : #{synerr.message}"
      rescue StandardError => err
        STDOUT.puts "Error while parsing file : #{file}"
        STDOUT.puts err.class,err.message,err.backtrace.join("\n")
      rescue Exception => ex
        STDOUT.puts "Error while parsing file : #{file}"
        STDOUT.puts ex.class,ex.message,ex.backtrace.join("\n")
      end
    end

    [idx_states, idx_tokens]
  end
end

if __FILE__ == $0
  require 'stringio'
  require 'getoptlong'
  require 'fileutils'
  require 'find'
  begin
    require 'rdoc/ri/ri_paths'
    require 'rdoc/usage'
  rescue
    # these requires cause problems in Ruby 1.9x that I'm not really sure how to fix 
  end
  include ResultIndexGenerator

  #Returns the path without the file
  def seperate_file_from_path(path)
    res = path.split("/")
    if res.size == 1
      ""
    else
      res[0..res.size - 2].join("/")
    end
  end

  def get_ruby_files(input_path)
    files = Array.new
    input_path.split("|").each do |path|
      Find.find(path.strip) do |f|
        files << f if !FileTest.directory?(f) && f =~ /\.rb$/
      end
    end
    files
  end

  files = Array.new
  output_dir = "./"
  formater = "html"
  state_filter = Filter.new(5)
  token_filter = Filter.new(10, 25, 50)
  comp_state = comp_token = false
  begin
    opt = GetoptLong.new(
       ["-o","--output_directory", GetoptLong::REQUIRED_ARGUMENT],
       ["-h","--help", GetoptLong::NO_ARGUMENT],
       ["-f","--formater", GetoptLong::REQUIRED_ARGUMENT],
       ["-c","--cyclo", GetoptLong::NO_ARGUMENT],
       ["-t","--token", GetoptLong::NO_ARGUMENT],
       ["-y","--filter_cyclo", GetoptLong::REQUIRED_ARGUMENT],
       ["-k","--filter_token", GetoptLong::REQUIRED_ARGUMENT],
       ["-w","--warn_cyclo", GetoptLong::REQUIRED_ARGUMENT],
       ["-s","--warn_token", GetoptLong::REQUIRED_ARGUMENT],
       ["-e","--error_cyclo", GetoptLong::REQUIRED_ARGUMENT],
       ["-d","--error_token", GetoptLong::REQUIRED_ARGUMENT],
       ["-p","--parse_file", GetoptLong::REQUIRED_ARGUMENT],
       ["-i","--input_directory", GetoptLong::REQUIRED_ARGUMENT],
       ["-v","--verbose", GetoptLong::NO_ARGUMENT]
       )

    opt.each do |arg,val|
      case arg
      when "-o"
        output_dir = val
      when "-h"
        RDoc.usage('help')
      when "-f"
        formater = val
      when "-c"
        comp_state = true
      when "-t"
        comp_token = true
      when "-k"
        token_filter.limit = val.to_i
      when "-s"
        token_filter.warn = val.to_i
      when "-d"
        token_filter.error = val.to_i
      when "-y"
        state_filter.limit = val.to_i
      when "-w"
        state_filter.warn = val.to_i
      when "-e"
        state_filter.error = val.to_i
      when "-p"
        files<< val
      when "-i"
        files.concat(get_ruby_files(val))
      when "-v"
        STDOUT.puts "Verbose mode on"
        $VERBOSE = true
      end

    end
    RDoc.usage if !comp_state && !comp_token
  rescue => err
    RDoc.usage
  end

  if formater =~ /html/i
    state_formater = StateHTMLComplexityFormater.new(STDOUT,state_filter)
    token_count_formater = HTMLTokenCounterFormater.new(STDOUT,token_filter)
  else
    state_formater = ParseStateFormater.new(STDOUT,state_filter)
    token_count_formater = TokenCounterFormater.new(STDOUT,token_filter)
  end

  state_formater = nil if !comp_state
  token_count_formater = nil if !comp_token

  idx_states, idx_tokens = Saikuro.analyze(files,
                                           state_formater,
                                           token_count_formater,
                                           output_dir)

  write_cyclo_index(idx_states, output_dir)
  write_token_index(idx_tokens, output_dir)
end
