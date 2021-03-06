defmodule Collision.Detection.SeparatingAxisTest do
  use ExUnit.Case
  use ExCheck
  alias Collision.Detection.SeparatingAxis
  alias Collision.Polygon
  alias Collision.Polygon.Vertex
  alias Collision.PolygonTest
  doctest Collision.Detection.SeparatingAxis

  # Generator for RegularPolygon values
  def polygon_at_origin do
    domain(:polygon_at_origin,
      fn(self, size) ->
        {_, s} = :triq_dom.pick(non_neg_integer, size)
        {_, r} = :triq_dom.pick(non_neg_integer, size)
        {_, a} = :triq_dom.pick(non_neg_integer, size)
        polygon = Polygon.gen_regular_polygon(max(s, 3), max(r, 1), a, {0, 0})
        {self, polygon}
      end,
      fn (self, polygon) ->
          {self, polygon}
          vertices = for vertex <- polygon.vertices do
            %Vertex{x: max(vertex.x - 2, 0), y: max(vertex.y - 2, 0)}
          end
          polygon = Polygon.from_vertices(vertices)
          {self, polygon}
      end)
  end

  property :polygons_with_the_same_midpoint_are_in_collision do
    for_all {p1, p2} in {polygon_at_origin, polygon_at_origin} do
      SeparatingAxis.collision?(p1, p2)
    end
  end

  property :polygons_in_collision_have_an_mtv do
    for_all {p1, p2} in such_that(
      {pp1, pp2} in {PolygonTest.polygon, PolygonTest.polygon}
      when Collidable.collision?(pp1, pp2)
    ) do
      !is_nil(SeparatingAxis.collision_mtv(p1, p2))
    end
  end

  @tag iterations: 500
  property :no_collision_gives_no_mtv do
    for_all {p1, p2} in {PolygonTest.polygon, PolygonTest.polygon} do
      implies (Collidable.collision?(p1, p2) == false) do
        is_nil(SeparatingAxis.collision_mtv(p1, p2))
      end
    end
  end
end
