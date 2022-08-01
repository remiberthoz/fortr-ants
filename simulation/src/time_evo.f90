module time_evo_mod
    use colony_mod
    use brain_mod, only: perception_x, perception_y
    use world_mod
    implicit none
    private
    public setup, timestep, timetick, clock_ellapsed, clock_avg_loop

    integer :: timetick = 0
    integer :: clock_start, clock_now, clock_rate, clock_max
    real :: clock_ellapsed, clock_avg_loop

contains

    subroutine setup(world, colony)
        class(World_t), intent(in) :: world
        class(Colony_t), intent(inout) :: colony
        integer, dimension(:, :), allocatable :: home_pos
        integer :: i, p
        real :: rnd

        call system_clock(clock_start, clock_rate, clock_max)

        home_pos = find_where_true(world%landscape_map(:, :, HOME_P) > 0)
        do i = 1, colony%n_ants
            call random_number(rnd)
            p = 1 + floor(real(size(home_pos, dim=2))*rnd)
            colony%positions(:, i) = real(home_pos(:, p))
            call random_number(rnd)
            colony%angles(i) = rnd * 2. * 3.14 - 3.14
        end do
        deallocate(home_pos)
        colony%holds_food(:) = .false.
        colony%distances(:) = 1
    end subroutine setup

    subroutine timestep(world, colony)
        class(World_t), intent(inout) :: world
        class(Colony_t), intent(inout) :: colony
        call animate_world(world)
        call animate_colony(colony, world)

        timetick = timetick + 1
        if (mod(timetick, 100) == 0) then
            call system_clock(clock_now)
            clock_ellapsed = real(clock_now - clock_start) / real(clock_rate)
            clock_avg_loop = clock_ellapsed / real(timetick)
            print *, timetick, clock_ellapsed, clock_avg_loop
        endif
    end subroutine timestep

    subroutine animate_world(world)
        class(World_t), intent(inout) :: world
        world%pheromone_map(:, :, 1) = world%pheromone_map(:, :, 1) * (1. - 1e-3)
        world%pheromone_map(:, :, 2) = world%pheromone_map(:, :, 2) * (1. - 1e-3)
    end subroutine animate_world

    subroutine animate_colony(colony, world)
        class(Colony_t), intent(inout) :: colony
        class(World_t), intent(inout) :: world
        integer :: i
        do i = 1, colony%n_ants
            call animate_ant(colony, world, i)
        end do
    end subroutine animate_colony

    subroutine animate_ant(colony, world, i)
        class(Colony_t), intent(inout) :: colony
        class(World_t), intent(inout) :: world
        integer :: i
        real :: decided_bearing, steer, new_a, new_x, new_y
        integer :: decided_drop_pheromone
        real :: decided_drop_amplitude
        real :: dangle = 3.14/3.

        associate (brain => colony%brains(i)%it, &
                x => colony%positions(1, i), &
                y => colony%positions(2, i), &
                a => colony%angles(i), &
                d => colony%distances(i), &
                holds_food => colony%holds_food(i) &
            )
            call world%perceive_at(nint(x), nint(y), perception_x, perception_y, brain%world_view)
            call brain%sense_and_decide(holds_food, d, brain%world_view, decided_bearing, decided_drop_pheromone, decided_drop_amplitude)

            if (decided_drop_pheromone == 1) then
                world%pheromone_map(nint(x), nint(y), 1) = max(world%pheromone_map(nint(x), nint(y), 1), decided_drop_amplitude)
            else
                world%pheromone_map(nint(x), nint(y), 2) = max(world%pheromone_map(nint(x), nint(y), 2), decided_drop_amplitude)
            endif

            new_x = x + cos(a)
            new_y = y + sin(a)
            steer = decided_bearing - a
            steer = sign(1.0, steer + 3.14) * mod(steer + 3.14, 2*3.14) - 3.14
            steer = min(max(steer, -dangle), +dangle)
            new_a = a + steer

            if (.not. world%landscape_map(nint(new_x), nint(new_y), WALL_P) > 0) then
                x = new_x
                y = new_y
                a = new_a
                d = d + 1
            else
                a = new_a + 3.14
            end if

            if (world%landscape_map(nint(x), nint(y), HOME_P) > 0) then
                d = 1
            else if (world%foodstock_map(nint(x), nint(y), 1) > 0) then
                d = 1
            endif

            if (holds_food .and. world%landscape_map(nint(x), nint(y), HOME_P) > 0) then
                holds_food = .false.
            else if ((.not. holds_food) .and. world%foodstock_map(nint(x), nint(y), 1) > 0) then
                holds_food = .true.
                world%foodstock_map(nint(x), nint(y), 1) = world%foodstock_map(nint(x), nint(y), 1) - 0.1
            end if
        end associate
    end subroutine animate_ant


    function find_where_true(array) result(positions)
        logical, dimension(:, :), intent(in) :: array
        integer, dimension(2, size(array)) :: positions_buffer
        integer, dimension(:, :), allocatable :: positions
        integer :: i, j, count = 0
        do j = 1, size(array, dim=2)
            do i = 1, size(array, dim=1)
                if (array(i, j)) then
                    count = count + 1
                    positions_buffer(:, count) = [i, j]
                end if
            end do
        end do
        allocate(positions(2, count))
        positions(:, :) = 0
        positions(:, :) = positions_buffer(:, :count)
    end function find_where_true

end module time_evo_mod
