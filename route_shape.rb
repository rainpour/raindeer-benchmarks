# frozen_string_literal: true

# The shape of every app's route table, picked with the ROUTES env var (100 or 1000, default 1000) and the PARAMS env
# var (set to 1 for routes with :id segments). Every app declares the same paths in the same order from `paths`.
#
# Static, like nested REST resources where a resource is addressable and has children:
#   1000: 390 plain solos + 10 solo parents x (20 plain duos + 10 duo parents x (1 + 3 trios))
#    100:  38 plain solos +  2 solo parents x (10 plain duos +  5 duo parents x (1 + 3 trios))
#
# With params, like REST collections and members (/posts, /posts/:id, /posts/:id/comments, /posts/:id/comments/:id):
#   1000: 200 solos x (collection + member) + 10 of them with 30 duos x (collection + member)
#    100:  20 solos x (collection + member) +  5 of them with  6 duos x (collection + member)
module RouteShape
  STATIC_SHAPES = {
    1000 => { solos: 400, solo_parents: 10, duos: 30, duo_parents: 10, trios: 3 },
    100 => { solos: 40, solo_parents: 2, duos: 15, duo_parents: 5, trios: 3 }
  }.freeze

  PARAM_SHAPES = {
    1000 => { solos: 200, solo_parents: 10, duos: 30 },
    100 => { solos: 20, solo_parents: 5, duos: 6 }
  }.freeze

  ROUTES = Integer(ENV.fetch('ROUTES', '1000'))
  PARAMS = ENV['PARAMS'] == '1'
  SHAPE = (PARAMS ? PARAM_SHAPES : STATIC_SHAPES).fetch(ROUTES)

  class << self
    # Every route path, in the order every app declares them. Parents come last, so the requested routes sit near
    # the end of a router that checks routes one by one.
    def paths
      PARAMS ? param_paths : static_paths
    end

    # The paths as a tree of segments, for routers that nest routes by segment, like Roda. Each node is
    # { route: true/false, children: { segment => node } }.
    def tree
      root = { route: false, children: {} }
      paths.each do |path|
        node = path.delete_prefix('/').split('/').reduce(root) do |parent, segment|
          parent[:children][segment] ||= { route: false, children: {} }
        end
        node[:route] = true
      end
      root
    end

    # The middle member of each route family, like /solo200 of /solo11 to /solo400, not the last one declared: Sinatra
    # and Roda match in declaration order, so a route near the end of the list is their worst case, not a typical
    # request.
    def test_paths
      PARAMS ? param_test_paths : static_test_paths
    end

    def report_name
      name = ['benchmark-report']
      name << ROUTES.to_s unless ROUTES == 1000
      name << 'params' if PARAMS
      "#{name.join('-')}.html"
    end

    private

    def static_paths
      plain_solos = ((SHAPE[:solo_parents] + 1)..SHAPE[:solos]).map { |s| "/solo#{s}" }
      parents = (1..SHAPE[:solo_parents]).flat_map do |s|
        plain_duos = ((SHAPE[:duo_parents] + 1)..SHAPE[:duos]).map { |d| "/solo#{s}/duo#{d}" }
        duo_parents = (1..SHAPE[:duo_parents]).flat_map do |d|
          ["/solo#{s}/duo#{d}", *(1..SHAPE[:trios]).map { |t| "/solo#{s}/duo#{d}/trio#{t}" }]
        end
        ["/solo#{s}", *plain_duos, *duo_parents]
      end
      plain_solos + parents
    end

    def param_paths
      plain_solos = ((SHAPE[:solo_parents] + 1)..SHAPE[:solos]).flat_map { |s| ["/solo#{s}", "/solo#{s}/:id"] }
      parents = (1..SHAPE[:solo_parents]).flat_map do |s|
        duos = (1..SHAPE[:duos]).flat_map { |d| ["/solo#{s}/:id/duo#{d}", "/solo#{s}/:id/duo#{d}/:duo_id"] }
        ["/solo#{s}", "/solo#{s}/:id", *duos]
      end
      plain_solos + parents
    end

    # Half of a count, rounded up, like 200 of 400 or 2 of 3.
    def middle(count) = (count + 1) / 2

    # For 1000 routes: /solo200 of the plain solos, /solo5/duo15 of solo5's duos, and /solo5/duo5/trio2.
    def static_test_paths
      s = middle(SHAPE[:solo_parents])
      d = middle(SHAPE[:duo_parents])
      {
        'GET /' => '/',
        '1 segment' => "/solo#{middle(SHAPE[:solos])}",
        '2 segments' => "/solo#{s}/duo#{middle(SHAPE[:duos])}",
        '3 segments' => "/solo#{s}/duo#{d}/trio#{middle(SHAPE[:trios])}"
      }
    end

    # For 1000 routes: /solo100 and its member of the plain solos, and /solo5's duo15 and its member.
    def param_test_paths
      plain = middle(SHAPE[:solos])
      s = middle(SHAPE[:solo_parents])
      d = middle(SHAPE[:duos])
      {
        'GET /' => '/',
        '1 segment' => "/solo#{plain}",
        '2 segments (:id)' => "/solo#{plain}/42",
        '3 segments' => "/solo#{s}/42/duo#{d}",
        '4 segments (:id)' => "/solo#{s}/42/duo#{d}/7"
      }
    end
  end
end
