module brain_mod
    use random_mod
    use world_mod
    implicit none
    private
    public Brain_t, brain_init, perception_x, perception_y, perception_channels

    integer, parameter :: perception_x = 4
    integer, parameter :: perception_y = 4
    integer, parameter :: perception_channels = 2

    type Brain_t
        class(World_t), allocatable :: world_view
        real, dimension(perception_x, perception_y, perception_channels) :: sensation
    contains
        procedure, pass :: sense_and_decide => sense_and_decide
    end type Brain_t

contains

    subroutine brain_init(self)
        class(Brain_t), intent(out), allocatable :: self
        allocate(self)
        call world_init(self%world_view, perception_x, perception_y)
    end subroutine brain_init

    subroutine sense_and_decide(self, holds_food, traveled_distance, world_view, steer_decision, pheromone_drop_decision, pheromone_drop_amplitude)
        class(Brain_t), intent(inout) :: self
        logical, intent(in) :: holds_food
        integer, intent(in) :: traveled_distance
        class(World_t), intent(in) :: world_view
        real, intent(out) :: steer_decision
        integer, intent(out) :: pheromone_drop_decision
        real, intent(out) :: pheromone_drop_amplitude
        integer, dimension(2) :: xy
        real, dimension(2) :: ij

        self%world_view%landscape_map(:, :, :) = world_view%landscape_map
        self%world_view%foodstock_map(:, :, :) = world_view%foodstock_map
        self%world_view%pheromone_map(:, :, 1) = jiggle_2d(world_view%pheromone_map(:, :, 1), 0.0000001)
        self%world_view%pheromone_map(:, :, 2) = jiggle_2d(world_view%pheromone_map(:, :, 2), 0.0000001)

        self%sensation = 0

        if (holds_food) then
            pheromone_drop_decision = 1
            pheromone_drop_amplitude = 1. * 0.995**traveled_distance
            xy = maxloc(self%world_view%pheromone_map(:, :, 2))
        else
            pheromone_drop_decision = 2
            pheromone_drop_amplitude = 1. * 0.995**traveled_distance
            xy = maxloc(self%world_view%pheromone_map(:, :, 1))
        endif

        ij = real(xy - 1) - real([perception_x-1, perception_y-1]) / 2.
        steer_decision = atan2(real(ij(2)), real(ij(1)))
    end subroutine sense_and_decide

end module brain_mod
