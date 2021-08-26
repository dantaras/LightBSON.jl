module LightBSON

using Dates
using DecFP
using FNVHash
using StructTypes
using Transducers
using UnsafeArrays
using UUIDs
using WeakRefStrings

export BSONConversionError
export BSONReader, BSONWriter, BSONWriteBuffer
export BSONIndex, IndexedBSONReader
export BSONTimestamp, BSONObjectId, BSONCode, BSONBinary, UnsafeBSONBinary, BSONRegex, UnsafeBSONString

export BSON_TYPE_DOUBLE,
    BSON_TYPE_STRING,
    BSON_TYPE_DOCUMENT,
    BSON_TYPE_ARRAY,
    BSON_TYPE_BINARY,
    BSON_TYPE_UNDEFINED,
    BSON_TYPE_OBJECTID,
    BSON_TYPE_BOOL,
    BSON_TYPE_DATETIME,
    BSON_TYPE_NULL,
    BSON_TYPE_REGEX,
    BSON_TYPE_DB_POINTER,
    BSON_TYPE_CODE,
    BSON_TYPE_SYMBOL,
    BSON_TYPE_CODE_WITH_SCOPE,
    BSON_TYPE_INT32,
    BSON_TYPE_TIMESTAMP,
    BSON_TYPE_INT64,
    BSON_TYPE_DECIMAL128

export BSON_SUBTYPE_GENERIC_BINARY,
    BSON_SUBTYPE_FUNCTION,
    BSON_SUBTYPE_BINARY_OLD,
    BSON_SUBTYPE_UUID_OLD,
    BSON_SUBTYPE_UUID,
    BSON_SUBTYPE_MD5,
    BSON_SUBTYPE_ENCRYPTED

const UnsafeBSONString = WeakRefString{UInt8}

struct BSONTimestamp
    counter::UInt32
    time::UInt32
end

BSONTimestamp(x::UInt64) = BSONTimestamp(x % UInt32, (x >> 32) % UInt32)

struct BSONObjectId
    data::NTuple{12, UInt8}
end

struct BSONCode
    code::String
end

struct BSONBinary
    data::Vector{UInt8}
    subtype::UInt8
end

BSONBinary(data::Vector{UInt8}) = BSONBinary(data, BSON_SUBTYPE_GENERIC_BINARY)

struct UnsafeBSONBinary
    data::UnsafeArray{UInt8, 1}
    subtype::UInt8
end

UnsafeBSONBinary(data::Vector{UInt8}) = UnsafeBSONBinary(data, BSON_SUBTYPE_GENERIC_BINARY)

struct BSONRegex
    pattern::String
    options::String
end

bson_simple(::Type{T}) where T = StructTypes.StructType(T) == StructTypes.NoStructType()

bson_supersimple(::Type{T}) where T = false

include("type.jl")
include("exceptions.jl")
include("reader.jl")
include("index.jl")
include("indexed_reader.jl")
include("writer.jl")
include("write_buffer.jl")

end
