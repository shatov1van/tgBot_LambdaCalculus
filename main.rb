require 'lyambda_gem'

include LyambdaGem

x = var("x")
y = var("y")
z = var("z")
u = var("u")
v = var("v")
p1 = var("p1")
p2 = var("p2")
i = var("i")

app1 = app(abs(x,  app( app(x,  app(x, app(y, z)) ), x)), abs(u, app(u, v)))

puts "((((yz)v)v)(λu.(uv)))"
puts app1
puts LyambdaGem::Reducer.to_normal(app1, verbose: true).to_s

term1 = app(abs(v, app(u, v)), app(v, v))
puts term1
puts Reducer.to_normal(term1, verbose: true).to_s

term1 = app(abs(x, abs(u, app(x, u))), u)
puts term1
puts Reducer.to_normal(term1, verbose: true).to_s

puts "################"
parser = LyambdaGem::Parser.new("(\\x. \\u. (x u)) p2 (\\i.p1)")
term1 = parser.parse
puts term1
puts Reducer.to_normal(term1, verbose: true).to_s

puts "################"
term1 = app(app(abs(x, abs(u, app(x, u))), p2), abs(i, p1))
puts term1
puts Reducer.to_normal(term1, verbose: true).to_s