# frozen_string_literal: true

# The shape of every app's route table, picked with the ROUTES env var
# (default 1000). Both sizes keep the same nested REST shape: plain solo
# leaves, solo parents with plain duo leaves, and duo parents with trio leaves.
#
#   1000: 390 plain solos + 10 solo parents x (20 plain duos + 10 duo parents x (1 + 3 trios))
#    100:  38 plain solos +  2 solo parents x (10 plain duos +  5 duo parents x (1 + 3 trios))
module RouteShape
  SHAPES = {
    1000 => { solos: 400, solo_parents: 10, duos: 30, duo_parents: 10, trios: 3 },
    100 => { solos: 40, solo_parents: 2, duos: 15, duo_parents: 5, trios: 3 }
  }.freeze

  ROUTES = Integer(ENV.fetch('ROUTES', '1000'))
  SHAPE = SHAPES.fetch(ROUTES)

  def self.plain_solos = ((SHAPE[:solo_parents] + 1)..SHAPE[:solos])
  def self.solo_parents = (1..SHAPE[:solo_parents])
  def self.plain_duos = ((SHAPE[:duo_parents] + 1)..SHAPE[:duos])
  def self.duo_parents = (1..SHAPE[:duo_parents])
  def self.trios = (1..SHAPE[:trios])

  # The last solo parent, its last duo parent, and that duo's last trio.
  def self.test_paths
    s = SHAPE[:solo_parents]
    d = SHAPE[:duo_parents]
    t = SHAPE[:trios]
    {
      'GET /' => '/',
      '1 segment' => "/solo#{s}",
      '2 segments' => "/solo#{s}/duo#{d}",
      '3 segments' => "/solo#{s}/duo#{d}/trio#{t}"
    }
  end
end
