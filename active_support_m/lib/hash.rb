# -*- encoding : utf-8 -*-
class Hash

  # hash取值 的时候先取符号号的，再取字符串   设置值的时候设成符号key
  def method_missing(method, *params)
    method_string = method.to_s
    if method_string.last == "="
      self[method.to_s[0...-1].to_sym] = params.first
    else
      self[method].nil? ? self[method_string] : self[method]
    end
  end
  
end
