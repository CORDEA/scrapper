import gleam/io
import gleam/hackney
import gleam/http.{Get}
import gleam/http/request

const host = "scrapbox.io"

const path = "/api/pages/"

pub fn main() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host(host)
    |> request.set_path(path)

  try res = hackney.send(req)
  io.debug(res.body)

  Ok(0)
}
