module MagicDicts

    export MagicDict

    ## -------------------------------------------------------------------
    struct MagicDict
        dict::Dict{Any, Any}
        MagicDict() = new(Dict())
        MagicDict(args) = new(Dict(args))
    end

    ## -------------------------------------------------------------------
    function Base.haskey(pd::MagicDict, k, ks...) 
        # early scape
        haskey(pd.dict, k) || return false 
        isempty(ks) && return true

        # check sub-dicts
        dict = pd.dict[k]
        dict isa Dict || return false
        for ki in ks[begin:end - 1]
            haskey(dict, ki) || return false
            dict = dict[ki]
            dict isa Dict || return false
        end

        # last key
        return haskey(dict, last(ks))
    end

    Base.get!(pd::MagicDict, defl, k, ks...) = haskey(pd, k, ks...) ? pd[k, ks...] : (pd[k, ks...] = defl)
    Base.get(pd::MagicDict, defl, k, ks...) = haskey(pd, k, ks...) ? pd[k, ks...] : defl
    Base.keys(pd::MagicDict)  = keys(pd.dict)
    Base.keys(pd::MagicDict, k, ks...)  = keys(pd[k, ks...])

    ## -------------------------------------------------------------------
    const ITERABLE = Union{AbstractVecOrMat, AbstractRange}
    _extract_keys(k, ks...) = tuple([ki isa ITERABLE ? ki : [ki] for ki in tuple(k, ks...)]...)
    _get_dict!(d::Dict, k) = (haskey(d, k) && d[k] isa Dict) ? d[k] : (d[k] = Dict{Any, Any}())

    ## -------------------------------------------------------------------
    Base.getindex(pd::MagicDict, k::ITERABLE) = [pd.dict[ki] for ki in k]
    function Base.getindex(pd::MagicDict, k, ks...) 
        if isempty(ks) 
            getindex(pd.dict, k)
        else
            cartesian = Iterators.product(_extract_keys(k, ks...)...) |> collect |> vec
            dat = []
            for kis in cartesian
                dati = pd.dict
                for ki in kis; dati = dati[ki]; end
                push!(dat, dati)
            end
            length(cartesian) == 1 ? first(dat) : dat
        end
    end

    ## -------------------------------------------------------------------
    function Base.setindex!(pd::MagicDict, v, k, ks...) 
        if isempty(ks) 
            setindex!(pd.dict, v, k)
        else
            cartesian = Iterators.product(_extract_keys(k, ks...)...) |> collect |> vec
            for kis in cartesian
                d = pd.dict
                for ki in kis[begin:end - 1]
                    d = _get_dict!(d, ki)
                end
                setindex!(d, v, last(kis))
            end
        end
    end


end
