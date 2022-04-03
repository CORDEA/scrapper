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
    list.first(args)
    |> map_error(fn(_e) { "Name is required." })
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host(host)
    |> request.set_path(string.append(to: path, suffix: name))

  try res =
    hackney.send(req)
    |> map_error(fn(_e) { "Failed to fetch." })

  let page_decoder =
    dynamic.decode4(
      Page,
      field("id", of: dynamic.string),
      field("title", of: dynamic.string),
      field("image", of: dynamic.optional(dynamic.string)),
      field("descriptions", of: dynamic.list(dynamic.string)),
    )
  let decoder = field("pages", of: dynamic.list(page_decoder))

  try json =
    json.decode(from: res.body, using: decoder)
    |> map_error(fn(_e) { "Failed to decode json." })

  json
  |> list.map(fn(r) { list.append([r.title, "\n"], r.descriptions) })
  |> list.map(fn(r) {
    list.fold(r, "", fn(a, b) { string.append(to: a, suffix: b) })
  })
  |> list.each(fn(r) { io.println(string.append(to: r, suffix: "\n")) })

  Ok(0)
}
