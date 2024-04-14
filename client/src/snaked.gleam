import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import gleam/queue.{type Queue}
import lustre/effect.{type Effect}
import prng/random

const canvas_x = 50

const canvas_y = 40

pub fn main() {
  lustre.application(init, update, view)
}

type State {
  State(player: PlayerState, other: PlayerState, food: Point)
}

type PlayerState {
  PlayerState(snek: Queue(Point), direction: Direction)
}

type Point {
  Point(x: Int, y: Int)
}

//## INIT
fn init(_flags) -> #(State, Effect(Msg)) {
  #(
    State(
      PlayerState(queue.new(), Up),
      PlayerState(queue.new(), Up),
      Point(0, 0),
    ),
    effect.none(),
  )
}

//## UPDATE
type Direction {
  Up
  Down
  Left
  Right
}

pub opaque type Msg {
  GameStarted
  PlayerMoved(Direction)
  SoundPlayed(String)
}

fn update(state: State, msg: Msg) -> #(State, Effect(Msg)) {
  case msg {
    GameStarted -> #(new_game(), game_started())
    PlayerMoved(direction) -> #(state, check_move(True, direction, state))
    _ -> todo as "not implemented yet"
  }
}

fn game_started() -> Effect(Msg) {
  effect.from(fn(dispatch) {
    get_sound("start_game")
    |> SoundPlayed
    |> dispatch
  })
  // dispatch other things....
}

fn get_sound(sound: String) -> String {
  sound
}

fn check_move(
  is_player: Bool,
  direction: Direction,
  state: State,
) -> Effect(Msg) {
  let #(mover, other, fruit) = case state {
    State(p, o, f) ->
      case is_player {
        True -> #(p, o, f)
        False -> #(o, p, f)
      }
  }

  let swallow_self = case direction, mover.direction {
    Up, Down | Down, Up | Left, Right | Right, Left -> True
    _, _ -> False
  }

  let head = case queue.pop_front(mover.snek) {
    Ok(#(head, _)) -> head
    _ -> panic as "couldnt get head"
  }

  let new_head = case queue.pop_front(mover.snek) {
    Ok(#(head, _)) -> {
      case direction {
        Up -> Point(head.x + 1, head.y)
        Down -> Point(head.x - 1, head.y)
        Left -> Point(head.x, head.y - 1)
        Right -> Point(head.x, head.y + 1)
      }
    }
    _ -> panic as "cant find sneks head"
  }

  effect.none()
}

fn new_game() -> State {
  // define two random points too start
  let generator_x = random.int(0, canvas_x)
  let generator_y = random.int(0, canvas_y)

  let player_start =
    Point(random.random_sample(generator_x), random.random_sample(generator_y))
  let other_start =
    Point(random.random_sample(generator_x), random.random_sample(generator_y))
  let fruit_point =
    Point(random.random_sample(generator_x), random.random_sample(generator_y))

  let player_queue =
    queue.new()
    |> queue.push_front(player_start)
  let other_queue =
    queue.new()
    |> queue.push_front(other_start)

  State(
    PlayerState(player_queue, Up),
    PlayerState(other_queue, Up),
    fruit_point,
  )
}
