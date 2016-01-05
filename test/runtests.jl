using TC
using Base.Test

immutable Iterable{T} <: TypeClass
  start::Arrow{Tuple{T},State{T}}
  next::Arrow{Tuple{T,State{T}},Tuple{Value{T},State{T}}}
  done::Arrow{Tuple{T,State{T}},Bool}
end
@generated iterable{T<:Iterable}( ::Type{T} ) = TC._is_of_type( T )?:Iterable: :T

immutable Enumerable{T} <: TypeClass
  _super::Tuple{Iterable{T}}
  length::Arrow{Tuple{T},Int64}
end

function foo{T}( arg::T, _is::Type{Iterable} = iterable( Iterable{T} ) )
  first( arg )
end

@test is_of_type( Iterable{Vector{Int64}}) == true
@test is_of_type( Iterable{Symbol}) == false
@test is_of_type( Enumerable{Vector{Int64}}) == true

function fails( x )
  try
    foo( x )
    return false
  catch e
    return true
  end
end

@test foo( [ 1,2,3]) == 1
@test fails( :symbol ) == true
