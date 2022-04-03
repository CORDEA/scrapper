import gleam/io
import gleam/hackney
import gleam/http.{Get}
import gleam/http/request
import gleam/list
import gleam/string
import gleam/result.{map_error}
import gleam/erlang.{start_arguments}

const host = "scrapbox.io"

const path = "/api/pages/"

pub fn main() {
  let args = start_arguments()
  try name =
    map_error(over: list.first(args), with: fn(_e) { "Name is required." })
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host(host)
    |> request.set_path(string.append(to: path, suffix: name))

  try res =
    map_error(over: hackney.send(req), with: fn(_e) { "Failed to fetch." })
  io.debug(res.body)

  Ok(0)
}
