program fortrants
    use brain_mod
    use world_mod
    use colony_mod
    use world_io_mod
    use time_evo_mod
    implicit none

    ! Simulation parameters
    integer, parameter :: n_ants = 500
    class(Colony_t), allocatable :: colony
    integer :: t_to_save = 0
    ! Command line parameters
    character(len=1024) :: world_path
    character(len=1024) :: output_path
    ! World
    class(World_t), allocatable :: world

    call signal(10, set_dump)
    call random_seed()
    ! Get cli params
    call get_command_argument(1, world_path)
    call get_command_argument(2, output_path)
    ! Initialize ants and world
    call colony_init(colony, n_ants)
    call read_world(world, world_path)
    call setup(world, colony)

    do while(.true.)
        if (t_to_save > 0) then
            t_to_save = t_to_save - 1
            call dump_colony(world, colony, output_path)
        endif
        call timestep(world, colony)
    end do

    call cleanup()

contains

    subroutine cleanup()
        deallocate(colony)
        deallocate(world)
    end subroutine cleanup

    subroutine set_dump()
        t_to_save = 150
    end subroutine set_dump

end program fortrants
