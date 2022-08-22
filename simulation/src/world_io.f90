module world_io_mod
    use world_mod
    use colony_mod
    use time_evo_mod, only: timetick, clock_ellapsed, clock_avg_loop
    use gif_module
    implicit none
    private
    public read_world, rgb_colony, rgb_init, rgb_finish

    integer, parameter :: color_wall_i = 1
    integer, parameter :: color_home_i = 2
    integer, parameter :: color_lake_i = 3
    integer, parameter :: color_food_i = 4
    integer, parameter :: color_ph1_i = 5
    integer, parameter :: color_ph2_i = 6

    integer, dimension(0:5, 0:5, 0:5, 0:1, 0:1, 0:1) :: colormap6
    integer, dimension(3, 0:255) :: colormapf

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

    function rgb_init(n, world, colony) result(pixels)
        integer, intent(in) :: n
        class(World_t), intent(in) :: world
        class(Colony_t), intent(in) :: colony
        integer, dimension(:, :, :), allocatable :: pixels
        allocate(pixels(n, size(world%landscape_map, dim=1), size(world%landscape_map, dim=2)))
        call colormap_init()
        ! do not forget to deallocate later
    end function rgb_init

    subroutine rgb_finish(pixels, path)
        integer, dimension(:, :, :), allocatable :: pixels
        character(len=*), intent(in) :: path
        call write_animated_gif(path, pixels, colormapf)
        deallocate(pixels)
    end subroutine rgb_finish

    subroutine rgb_colony(world, colony, pixels)
        class(World_t), intent(in) :: world
        class(Colony_t), intent(in) :: colony
        integer, dimension(:, :), intent(inout) :: pixels
        integer :: x, y
        pixels = 0
        associate (landscape => world%landscape_map, pheromone => world%pheromone_map, foodstock => world%foodstock_map)
            do y = 1, size(pixels, dim=2)
                do x = 1, size(pixels, dim=1)
                    pixels(x, y) = colormap6(floor(5. * foodstock(x, y, 1)), floor(5. * pheromone(x, y, PH1_P)), floor(5. * pheromone(x, y, PH2_P)), 0, 0, 0)
                    if (landscape(x, y, WALL_P) > 0) then
                        pixels(x, y) = colormap6(0, 0, 0, 1, 0, 0)
                    else if (landscape(x, y, HOME_P) > 0) then
                        pixels(x, y) = colormap6(0, 0, 0, 0, 1, 0)
                    else if (landscape(x, y, LAKE_P) > 0) then
                        pixels(x, y) = colormap6(0, 0, 0, 0, 0, 1)
                    end if
                end do
            end do
        end associate
        do x = 1, colony%n_ants
            pixels(nint(colony%positions(1, x)), nint(colony%positions(2, x))) = colormap6(0, 0, 0, 1, 0, 0)
            if (colony%holds_food(x)) then
                pixels(nint(colony%positions(1, x))+1, nint(colony%positions(2, x))) = colormap6(0, 0, 0, 1, 0, 0)
                pixels(nint(colony%positions(1, x))-1, nint(colony%positions(2, x))) = colormap6(0, 0, 0, 1, 0, 0)
                pixels(nint(colony%positions(1, x)), nint(colony%positions(2, x))+1) = colormap6(0, 0, 0, 1, 0, 0)
                pixels(nint(colony%positions(1, x)), nint(colony%positions(2, x))-1) = colormap6(0, 0, 0, 1, 0, 0)
            end if
        end do
    end subroutine rgb_colony

    function adjust_color(color, brightness) result(adjusted)
        integer, dimension(3), intent(in) :: color
        real, intent(in) :: brightness
        integer, dimension(3) :: adjusted
        adjusted = int(real(color) * real(floor(6. * brightness)) / 6.)
    end function adjust_color

    subroutine colormap_init()
        integer :: food, ph1, ph2
        colormap6 = 0
        colormap6(:, :, :, 1, 0, 0) = color_wall_i
        colormap6(:, :, :, 0, 1, 0) = color_home_i
        colormap6(:, :, :, 0, 0, 1) = color_lake_i
        colormapf(:, 0) = 0
        colormapf(:, color_wall_i) = color_wall
        colormapf(:, color_home_i) = color_home
        colormapf(:, color_lake_i) = color_lake
        do ph2 = 0, 5
            do ph1 = 0, 5
                do food = 0, 5
                    colormap6(food, ph1, ph2, 0, 0, 0) = 4 + food+ph1*6+ph2*6*6
                    colormapf(:, 4+food+ph1*6+ph2*6*6) = min(255, adjust_color(color_food, real(food)/6.) + adjust_color(color_ph1, real(ph1)/6.) + adjust_color(color_ph2, real(ph2)/6.))
                end do
            end do
        end do
    end subroutine colormap_init

end module world_io_mod
