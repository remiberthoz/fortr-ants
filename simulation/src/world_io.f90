module world_io_mod
    use world_mod
    use colony_mod
    use time_evo_mod, only: timetick, clock_ellapsed, clock_avg_loop
    implicit none
    private
    public read_world, dump_colony

    integer, dimension(3) :: color_wall = [int(z'56'), int(z'b9'), int(z'00')]
    integer, dimension(3) :: color_home = [int(z'ff'), int(z'fb'), int(z'5d')]
    integer, dimension(3) :: color_lake = [int(z'5d'), int(z'61'), int(z'ff')]
    integer, dimension(3) :: color_food = [int(z'ff'), int(z'00'), int(z'e5')]
    integer, dimension(3) :: color_ph1  = [int(z'ff'), int(z'00'), int(z'00')]
    integer, dimension(3) :: color_ph2  = [int(z'00'), int(z'00'), int(z'ff')]

contains

    subroutine read_world(new, dat_path)
        class(World_t), intent(out), allocatable :: new
        character(len=1024), intent(in) :: dat_path

        integer, dimension(:, :, :), allocatable :: rgb_world
        integer :: world_size_x, world_size_y, x, y
        integer :: foo

        open(file=dat_path, action='read', newunit=foo, form='unformatted')
        read(foo) world_size_y
        read(foo) world_size_x

        allocate(rgb_world(3, world_size_x, world_size_y))
        call world_init(new, world_size_x, world_size_y)

        read(foo) rgb_world
        close(foo)

        new%landscape_map = 0
        new%foodstock_map = 0
        new%pheromone_map = 0

        do y = 1, world_size_y
            do x = 1, world_size_x
                if (all(rgb_world(:, x, y) == color_lake)) then
                    new%landscape_map(x, y, WALL_P) = 1
                else if (all(rgb_world(:, x, y) == color_wall)) then
                    new%landscape_map(x, y, WALL_P) = 1
                else if (all(rgb_world(:, x, y) == color_home)) then
                    new%landscape_map(x, y, HOME_P) = 1
                else if (all(rgb_world(:, x, y) == color_food)) then
                    new%foodstock_map(x, y, 1) = 1
                ! else if (all(rgb_world(:, x, y) == color_ph1)) then
                !     new%pheromone_map(x, y, PH1_P) = 1
                ! else if (all(rgb_world(:, x, y) == color_ph2)) then
                !     new%pheromone_map(x, y, PH2_P) = 1
                end if
            end do
        end do

        deallocate(rgb_world)
    end subroutine read_world


    subroutine dump_colony(world, colony, output_path)
        class(World_t), intent(in) :: world
        class(Colony_t), intent(in) :: colony
        character(len=1024), intent(in) :: output_path

        integer, dimension(3, size(world%landscape_map, dim=1), size(world%landscape_map, dim=2)) :: rgb
        integer :: x, y
        integer :: foo

        print *, 'Dumping'
        rgb = 0

        open(file=output_path, action='write', position='append', newunit=foo, form='unformatted')
        associate (landscape => world%landscape_map, pheromone => world%pheromone_map, foodstock => world%foodstock_map)
            do y = 1, size(rgb, dim=3)
                do x = 1, size(rgb, dim=2)
                    if (landscape(x, y, LAKE_P) > 0) then
                        rgb(:, x, y) = color_lake
                    else if (landscape(x, y, WALL_P) > 0) then
                        rgb(:, x, y) = color_wall
                    else if (landscape(x, y, HOME_P) > 0) then
                        rgb(:, x, y) = color_home
                    else if (foodstock(x, y, 1) > 0) then
                        rgb(:, x, y) = int(real(color_food) * foodstock(x, y, 1))
                    end if
                    if (pheromone(x, y, PH1_P) > 0) then
                        rgb(:, x, y) = rgb(:, x, y) + int(real(color_ph1) * pheromone(x, y, PH1_P))
                    end if
                    if (pheromone(x, y, PH2_P) > 0) then
                        rgb(:, x, y) = rgb(:, x, y) + int(real(color_ph2) * pheromone(x, y, PH2_P))
                    end if
                end do
            end do
        end associate
        write(foo) 0
        write(foo) timetick
        write(foo) clock_ellapsed
        write(foo) clock_avg_loop
        write(foo) size(world%landscape_map, dim=2)
        write(foo) size(world%landscape_map, dim=1)
        write(foo) rgb
        write(foo) colony%n_ants
        write(foo) colony%positions
        write(foo) colony%angles
        write(foo) colony%holds_food
        close(foo)
    end subroutine dump_colony

end module world_io_mod
