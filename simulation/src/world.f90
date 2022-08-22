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

    subroutine perceive_at(self, cx, cy, angle, dx, dy, allocated_output)
        class(World_t), intent(in) :: self
        real, intent(in) :: cx, cy, angle
        integer, intent(in) :: dx, dy
        class(World_t), intent(inout) :: allocated_output
        real, dimension(2*dx, 2*dy, 6) :: intermediate
        real :: in_d, in_theta
        integer :: out_x, out_y, in_i, in_j, in_x, in_y
        do out_x = 1, 2*dx
            do out_y = 1, 2*dy
                ! (x, y) = raster coordinates from top left (top left = 1, 1)
                ! (i, j) = cartesian coordinates from center (center = cx, cy)
                ! (d, theta) = polar coordinates from center
                in_i = - dx + out_x - 1
                in_j = - dy + out_y - 1
                in_d = sqrt(real(in_i**2 + in_j**2))
                in_theta = atan2(real(in_j), real(in_i)) + angle
                ! (in_x, in_y) <-- cartesian coordinates in pre-rot image wrt (0, 0)
                ! TODO should be named truei, truej or origi, origj ?
                in_x = floor(cx + in_d * cos(in_theta))
                in_y = floor(cy + in_d * sin(in_theta))
                ! Assign with interpolation
                intermediate(out_x, out_y, 1:3) = self%landscape_map(in_x, in_y, :)
                intermediate(out_x, out_y, 4:5) = self%pheromone_map(in_x, in_y, :)
                intermediate(out_x, out_y, 6:6) = self%foodstock_map(in_x, in_y, :)
            end do
        end do
        allocated_output%landscape_map = intermediate(dx/2+1:3*dx/2, dy/2+1:3*dy/2, 1:3)
        allocated_output%pheromone_map = intermediate(dx/2+1:3*dx/2, dy/2+1:3*dy/2, 4:5)
        allocated_output%foodstock_map = intermediate(dx/2+1:3*dx/2, dy/2+1:3*dy/2, 6:6)
    end subroutine perceive_at

end module world_mod
