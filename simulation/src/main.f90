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
    integer :: frames_to_save = 0, frame_save_interval, t_to_next_save
    logical :: stop_after_save = .false.
    ! Command line parameters
    character(len=1024) :: world_path
    character(len=1024) :: output_path
    character(len=1024) :: dump_params_path
    ! World
    class(World_t), allocatable :: world
    integer, dimension(:, :, :), allocatable :: pixels
    integer :: pixels_last_t

    call signal(10, set_dump)
    call random_seed()
    ! Get cli params
    call get_command_argument(1, world_path)
    call get_command_argument(2, output_path)
    call get_command_argument(3, dump_params_path)
    ! Initialize ants and world
    call colony_init(colony, n_ants)
    call read_world(world, world_path)
    call setup(world, colony)

    do while(.true.)
        if (frames_to_save > 0 .and. t_to_next_save == 0) then
            if (.not. allocated(pixels)) then
                pixels_last_t = 0
                pixels = rgb_init(frames_to_save, world, colony)
            end if
            pixels_last_t = pixels_last_t + 1
            print *, 'saving: ', pixels_last_t
            call rgb_colony(world, colony, pixels(pixels_last_t, :, :))
            frames_to_save = frames_to_save - 1
            if (frames_to_save > 0) then
                t_to_next_save = frame_save_interval
            endif
        endif
        if (frames_to_save == 0 .and. allocated(pixels)) then
            print *, 'finishing'
            call rgb_finish(pixels, output_path)
        end if
        if (frames_to_save == 0 .and. stop_after_save) then
            print *, "Stopping..."
            call sleep(1)
            cycle
        endif
        call timestep(world, colony)
        t_to_next_save = t_to_next_save - 1
    end do

    call cleanup()

contains

    subroutine cleanup()
        deallocate(colony)
        deallocate(world)
    end subroutine cleanup

    subroutine set_dump()
        integer :: save_duration, foo
        open(file=dump_params_path, action='read', newunit=foo)
        read(foo, *) save_duration, frames_to_save, stop_after_save
        close(foo)
        frames_to_save = min(frames_to_save, 500)
        frame_save_interval = nint(real(save_duration) / real(frames_to_save))
        t_to_next_save = frame_save_interval
    end subroutine set_dump

end program fortrants
