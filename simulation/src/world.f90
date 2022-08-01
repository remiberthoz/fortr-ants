module world_mod
    implicit none
    private
    public World_t, world_init, LAKE_P, WALL_P, HOME_P, PH1_P, PH2_P

    integer, parameter :: LAKE_P = 1
    integer, parameter :: WALL_P = 2
    integer, parameter :: HOME_P = 3

    integer, parameter :: PH1_P = 1
    integer, parameter :: PH2_P = 2

    type World_t
        real, dimension(:, :, :), allocatable :: landscape_map
        real, dimension(:, :, :), allocatable :: pheromone_map
        real, dimension(:, :, :), allocatable :: foodstock_map
    contains
        procedure, pass :: perceive_at => perceive_at
    end type World_t

contains

    subroutine world_init(self, size_x, size_y)
        class(World_t), allocatable, intent(out) :: self
        integer, intent(in) :: size_x, size_y
        allocate(self)
        allocate(self%landscape_map(size_x, size_y, 3))
        allocate(self%pheromone_map(size_x, size_y, 2))
        allocate(self%foodstock_map(size_x, size_y, 1))
    end subroutine world_init

    subroutine perceive_at(self, cx, cy, dx, dy, allocated_output)
        class(World_t), intent(in) :: self
        integer, intent(in) :: cx, cy, dx, dy
        class(World_t), intent(inout) :: allocated_output
        integer :: sx, sy
        sx = cx - dx/2
        sy = cy - dy/2
        allocated_output%landscape_map(:, :, :) = self%landscape_map(sx:sx+dx-1, sy:sy+dy-1, :)
        allocated_output%pheromone_map(:, :, :) = self%pheromone_map(sx:sx+dx-1, sy:sy+dy-1, :)
        allocated_output%foodstock_map(:, :, :) = self%foodstock_map(sx:sx+dx-1, sy:sy+dy-1, :)
    end subroutine perceive_at

end module world_mod
