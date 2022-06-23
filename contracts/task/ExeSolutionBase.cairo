%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

from starkware.starknet.common.syscalls import get_caller_address
 
struct Animal:
    member sex : felt
    member legs : felt
    member wings : felt
end

@storage_var
func animal_of_token(token_id: Uint256) -> (animal: Animal):
end

@view
func get_animal_characteristics{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256) -> (sex : felt, legs : felt, wings : felt):
    alloc_locals
    let (animal) = animal_of_token.read(token_id)
    return (animal.sex, animal.legs, animal.wings)
end

@view
func is_breeder(account : felt) -> (is_approved : felt):
    return (1)
end
@view
func registration_price() -> (price : Uint256):
    return (Uint256(100,0))
end

@external
func register_me_as_breeder() -> (is_added : felt):
    return (1)
end

func declare_animal_internal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, sex : felt, legs : felt, wings : felt) -> (newAnimal : Animal):
    let newAnimal = Animal(sex=sex, legs=legs, wings=wings)
    animal_of_token.write(token_id, newAnimal)
    return (newAnimal)
end

@view
func token_of_owner_by_index(account : felt, index : felt) -> (token_id : Uint256):
    return (Uint256(100,0))
end
func declare_dead_animal_internal(token_id : Uint256):
    return ()
end