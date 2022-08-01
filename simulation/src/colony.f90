module colony_mod
    use brain_mod
    implicit none
    private
    public Colony_t, colony_init

    type Colony_t
        integer :: n_ants
        class(BrainHolder_t), dimension(:), allocatable :: brains
        real, dimension(:, :), allocatable :: positions
        real, dimension(:), allocatable :: angles
        logical, dimension(:), allocatable :: holds_food
        integer, dimension(:), allocatable :: distances
    end type Colony_t

    type BrainHolder_t
        class(Brain_t), allocatable :: it
    end type BrainHolder_t

contains

    subroutine colony_init(self, n_ants)
        class(Colony_t), intent(out), allocatable :: self
        integer, intent(in) :: n_ants
        integer :: i
        allocate(self)
        self%n_ants = n_ants
        allocate(self%brains(n_ants))
        do i = 1, n_ants
            call brain_init(self%brains(i)%it)
        end do
        allocate(self%positions(2, n_ants))
        allocate(self%angles(n_ants))
        allocate(self%holds_food(n_ants))
        allocate(self%distances(n_ants))
    end subroutine colony_init

end module colony_mod
