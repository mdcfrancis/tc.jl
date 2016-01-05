using TC
using Base.Test

function foo{T}( arg::T, _is::Type{TC.Iterable} = TC.iterable( TC.Iterable{T} ) )
  first( arg )
end

@test TC.is_of_type( TC.Iterable{Vector{Int64}}) == true
@test TC.is_of_type( TC.Iterable{Symbol}) == false
@test TC.is_of_type( TC.Enumerable{Vector{Int64}}) == true

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
