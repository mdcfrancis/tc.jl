module TC
abstract TypeClass
abstract Arrow{A,R}
abstract Value{T}
abstract State{T}

export Arrow, Value, State, TypeClass, is_of_type

deref{T}( ::Type{T} ) = T.parameters[1]

totype{T}( t::Type{T} ) = T
totype{T}( t::Type{Value{T}}) = retval(next, Tuple{T,totype(State{T})}).parameters[1]
totype{T}( t::Type{State{T}}) = retval(start, Tuple{T} )

function retval{A}(func::Function, ::Type{A})
  ct = code_typed( func, A )
  (length( ct ) < 1 || length( ct[1].args ) < 3) && return Any
  return ct[1].args[3].typ
end

function norm{T<:Tuple}( ::Type{T})
  converted = map(totype, T.parameters )
  return eval(current_module(), parse( "Tuple{$(join(converted, ","))}" ))
end

function norm{T}( ::Type{T})
  return totype( T )
end

# Recursive definition for inherited properties
function check_sig{T<:Tuple}( t::Type{T}, f::Symbol )
  contains( (typ,comp) -> comp == contains( (f,comp)->comp == check_sig( fieldtype( typ, f ) ,f ), fieldnames( typ ), false), t.parameters, false )
end

function check_sig{A,R}( t::Type{Arrow{A,R}}, f::Symbol )
  func = eval( current_module(), f )
  an = norm(A)
  rn = norm(R)
  ret = method_exists( func, an ) && rn == retval( func, an )
  !ret && warn( "checking function '$f' mismatch signature $A -> $R ")
  return ret
end

_is_of_type{T}( ::Type{T}) = false
function _is_of_type{TTC<:TypeClass}( typ::Type{TTC} )
  return !contains( (f,comp)->comp == check_sig( fieldtype( typ, f ) ,f ), fieldnames( typ ), false)
end

@generated function is_of_type{TTC<:TypeClass}( typ::Type{TTC} )
  _is_of_type(deref( typ ))?:(true) : :(false)
end

end
