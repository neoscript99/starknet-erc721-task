%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub, uint256_eq

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from contracts.token.ERC20.IERC20 import IERC20
from openzeppelin.token.erc721.library import (
    ERC721_mint,
    ERC721_burn,
    ERC721_balanceOf,
    ERC721_ownerOf,
)

struct Animal:
    member sex : felt
    member legs : felt
    member wings : felt
end

@storage_var
func animal_of_token(token_id : Uint256) -> (animal : Animal):
end
@storage_var
func tokens_of_owner(owner : felt, index : felt) -> (token_id : Uint256):
end
@storage_var
func owner_cur_index(owner : felt) -> (index : felt):
end
@storage_var
func cur_token_id() -> (token_id : Uint256):
end
@storage_var
func breeders(account : felt) -> (approved : felt):
end

@storage_var
func dummy_token_address_storage() -> (dummy_token_address_storage : felt):
end

func Solution_init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    dummy_token_address : felt
):
    dummy_token_address_storage.write(dummy_token_address)
    return ()
end

@view
func get_animal_characteristics{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (sex : felt, legs : felt, wings : felt):
    alloc_locals
    let (animal) = animal_of_token.read(token_id)
    return (animal.sex, animal.legs, animal.wings)
end

@view
func is_breeder{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (is_approved : felt):
    let (is_approved) = breeders.read(account)
    return (is_approved)
end
@view
func registration_price() -> (price : Uint256):
    return (Uint256(1 * 1000000000000000000, 0))
end

@external
func register_me_as_breeder{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    ) -> (is_added : felt):
    alloc_locals
    let (local sender_address) = get_caller_address()
    let (local solution_address) = get_contract_address()
    let (local price) = registration_price()

    let (dummy_token_address) = dummy_token_address_storage.read()
    with_attr error_message("net enough dummy token for registration price"):
        IERC20.transferFrom(
            contract_address=dummy_token_address,
            sender=sender_address,
            recipient=solution_address,
            amount=price,
        )
    end
    breeders.write(sender_address, 1)
    return (1)
end

@external
func declare_animal{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    sex : felt, legs : felt, wings : felt
) -> (token_id : Uint256):
    alloc_locals
    # Reading caller address
    let (local sender_address) = get_caller_address()

    let (is_approved) = breeders.read(sender_address)

    with_attr error_message("sender_address is not a breeder"):
        assert is_approved = 1
    end

    let (local token_id) = Solution_mint(sender_address)
    declare_animal_internal(token_id=token_id, sex=sex, legs=legs, wings=wings)
    let (local cur_index) = owner_cur_index.read(sender_address)
    tokens_of_owner.write(sender_address, cur_index + 1, token_id)
    owner_cur_index.write(sender_address, cur_index + 1)
    return (token_id)
end

func Solution_mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    to : felt
) -> (token_id : Uint256):
    alloc_locals
    let (token_id) = cur_token_id.read()
    let (local next_token_id, _) = uint256_add(token_id, Uint256(1, 0))
    ERC721_mint(to, next_token_id)
    cur_token_id.write(next_token_id)
    return (next_token_id)
end
func declare_animal_internal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256, sex : felt, legs : felt, wings : felt
) -> (newAnimal : Animal):
    let newAnimal = Animal(sex=sex, legs=legs, wings=wings)
    animal_of_token.write(token_id, newAnimal)
    return (newAnimal)
end

@view
func token_of_owner_by_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt, index : felt
) -> (token_id : Uint256):
    return tokens_of_owner.read(account, index + 1)
end

@external
func declare_dead_animal{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256
):
    alloc_locals
    let (local caller) = get_caller_address()
    let (local owner) = ERC721_ownerOf(token_id)
    with_attr error_message("Ownable: caller is not the owner"):
        assert owner = caller
    end
    ERC721_burn(token_id)
    declare_dead_animal_internal(owner, token_id)
    return ()
end

func get_token_index{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, token_id : Uint256, cur_index : felt
) -> (index : felt):
    alloc_locals
    if cur_index == 0:
        return (0)
    end
    let (local cur_token_id) = tokens_of_owner.read(owner, cur_index)
    let (local is_eq) = uint256_eq(token_id, cur_token_id)
    if is_eq == 1:
        return (cur_index)
    else:
        return get_token_index(owner, token_id, cur_index - 1)
    end
end
# 0 0 0 represent dead
func declare_dead_animal_internal{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(owner : felt, token_id : Uint256):
    alloc_locals
    declare_animal_internal(token_id, 0, 0, 0)
    let (local cur_index) = owner_cur_index.read(owner)
    let (local index) = get_token_index(owner, token_id, cur_index)
    if index == 0:
        return ()
    end
    let (local last_token_id) = tokens_of_owner.read(owner, cur_index)
    tokens_of_owner.write(owner, index, last_token_id)
    owner_cur_index.write(owner, cur_index - 1)
    return ()
end
