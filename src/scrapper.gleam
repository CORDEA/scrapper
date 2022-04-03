import gleam/io
import gleam/hackney
import gleam/http.{Get}
import gleam/http/request
import gleam/list
import gleam/json
import gleam/string
import gleam/option.{Option}
import gleam/result.{map_error}
import gleam/erlang.{start_arguments}
import gleam/dynamic.{field}

const host = "scrapbox.io"

const path = "/api/pages/"

type Page {
  Page(
    id: String,
    title: String,
    image: Option(String),
    descriptions: List(String),
  )
}

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

  let page_decoder =
    dynamic.decode4(
      Page,
      field("id", of: dynamic.string),
      field("title", of: dynamic.string),
      field("image", of: dynamic.optional(dynamic.string)),
      field("descriptions", of: dynamic.list(dynamic.string)),
    )
  let decoder = field("pages", of: dynamic.list(page_decoder))
  let json = json.decode(from: res.body, using: decoder)
  io.debug(json)

  Ok(0)
}
