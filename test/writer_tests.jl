@testset "Writer" begin

# NOTE: Not ideal to be testing with dependence on reader,
#       but reader is tested on expected byte representations so assuming reader is good this is a lot easier
@testset "single field $(typeof(x))" for x in [
    Int32(123),
    Int64(123),
    1.25,
    d128"1.25",
    true,
    nothing,
    DateTime(2021, 1, 2, 9, 30),
    BSONTimestamp(1, 2),
    BSONObjectId((
        0x1, 0x2, 0x3, 0x4,
        0x5, 0x6, 0x7, 0x8,
        0x9, 0xA, 0xB, 0xC,
    )),
    "test",
    BSONBinary([0x1, 0x2, 0x3]),
    uuid4(),
    BSONCode("f() = 1;"),
    BSONRegex("test", "abc"),
]
    buf = UInt8[]
    writer = BSONWriter(buf)
    writer["x"] = x
    close(writer)
    BSONReader(buf)["x"][typeof(x)] == x
end

@testset "document" begin
    buf = UInt8[]
    writer = BSONWriter(buf)
    writer["x"] = w -> begin
        w["a"] = 1
        w["b"] = 2
    end
    close(writer)
    reader = BSONReader(buf)
    @test reader["x"].type == BSON_TYPE_DOCUMENT
    @test reader["x"]["a"][Int] == 1
    @test reader["x"]["b"][Int] == 2
end

@testset "array" begin
    buf = UInt8[]
    writer = BSONWriter(buf)
    writer["x"] = [1, 2, 3]
    close(writer)
    reader = BSONReader(buf)
    @test reader["x"].type == BSON_TYPE_ARRAY
    @test reader["x"][Vector{Int}] == [1, 2, 3]
end

@testset "array generator" begin
    buf = UInt8[]
    writer = BSONWriter(buf)
    writer["x"] = (x * x for x in 1:3)
    close(writer)
    reader = BSONReader(buf)
    @test reader["x"].type == BSON_TYPE_ARRAY
    @test reader["x"][Vector{Int}] == [1, 4, 9]
end

@testset "array generator documents" begin
    buf = UInt8[]
    writer = BSONWriter(buf)
    writer["x"] = (
        w -> begin
            w["a"] = x
            w["b"] = x * x
        end
        for x in 1:3
    )
    close(writer)
    reader = BSONReader(buf)
    @test reader["x"].type == BSON_TYPE_ARRAY
    @test reader["x"]["0"].type == BSON_TYPE_DOCUMENT
    @test reader["x"]["0"]["a"][Int] == 1
    @test reader["x"]["0"]["b"][Int] == 1
    @test reader["x"]["1"].type == BSON_TYPE_DOCUMENT
    @test reader["x"]["1"]["a"][Int] == 2
    @test reader["x"]["1"]["b"][Int] == 4
    @test reader["x"]["2"].type == BSON_TYPE_DOCUMENT
    @test reader["x"]["2"]["a"][Int] == 3
    @test reader["x"]["2"]["b"][Int] == 9
end

end