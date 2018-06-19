require "recent_ruby/version"
require 'parser/current'
require 'rexml/document'

module RecentRuby

# Class comes from: https://medium.com/rubyinside/using-xpath-to-rewrite-ruby-code-with-ease-8f635af65b5b
# TODO: turn into a separate gem

	class XMLAST
		include REXML
		attr_reader :doc

		def initialize sexp
		  @doc = Document.new "<root></root>"
		  @sexp = sexp
		  root = @doc.root
		  populate_tree(root, sexp)
		end

		def populate_tree xml, sexp
		  if sexp.is_a?(String) ||
		      sexp.is_a?(Symbol) ||
		      sexp.is_a?(Numeric) ||
		      sexp.is_a?(NilClass)
		    el = Element.new(sexp.class.to_s.downcase + "-val")
		    el.add_attribute 'value', sexp.to_s
		    xml.add_element el
		  else
		    el = Element.new(sexp.type.to_s)
		    el.add_attribute('id', sexp.object_id)

		    sexp.children.each{ |n| populate_tree(el, n) }
		    xml.add_element el
		  end
		end

		def treewalk sexp=@sexp
		  return sexp unless sexp&.respond_to?(:children)
		  [sexp, sexp.children.map {|n| treewalk(n) }].flatten
		end

		def xpath path
		  results = XPath.match(doc, path)
		  results.map do |n|
		    if n.respond_to?(:attributes) && n.attributes['id']
		      treewalk.find do |m| 
		        m.object_id.to_s == n.attributes['id']
		      end
		    else
		      n
		    end
		  end
		end
	end
end
