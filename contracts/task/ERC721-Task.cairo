%lang starknet

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_le,
    uint256_lt,
    uint256_check,
    uint256_eq,
)

from openzeppelin.token.erc721.library import (
    ERC721_name,
    ERC721_symbol,
    ERC721_balanceOf,
    ERC721_ownerOf,
    ERC721_getApproved,
    ERC721_isApprovedForAll,
    ERC721_mint,
    ERC721_burn,
    ERC721_initializer,
    ERC721_approve,
    ERC721_setApprovalForAll,
    ERC721_transferFrom,
    ERC721_safeTransferFrom,
)

from contracts.task.ExeSolutionBase import(
    get_animal_characteristics,
    is_breeder,
    registration_price,
    register_me_as_breeder,
    token_of_owner_by_index,
    declare_animal_internal,
    declare_dead_animal_internal
)
#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt, symbol : felt, to_ : felt
):
    ERC721_initializer(name, symbol)
    let to = to_
    let token_id : Uint256 = Uint256(1, 0)
    ERC721_mint(to, token_id)
    cur_token_id.write(token_id)
    return ()
end

@storage_var
func cur_token_id() -> (token_id: Uint256):
end
#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC721_name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC721_symbol()
    return (symbol)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt) -> (
    balance : Uint256
):
    let (balance : Uint256) = ERC721_balanceOf(owner)
    return (balance)
end

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (owner : felt):
    let (owner : felt) = ERC721_ownerOf(token_id)
    return (owner)
end

@view
func getApproved{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (approved : felt):
    let (approved : felt) = ERC721_getApproved(token_id)
    return (approved)
end

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, operator : felt
) -> (is_approved : felt):
    let (is_approved : felt) = ERC721_isApprovedForAll(owner, operator)
    return (is_approved)
end

#
# Externals
#

@external
func approve{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    to : felt, token_id : Uint256
):
    ERC721_approve(to, token_id)
    return ()
end

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
):
    ERC721_setApprovalForAll(operator, approved)
    return ()
end

@external
func transferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256
):
    ERC721_transferFrom(_from, to, token_id)
    return ()
end

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256, data_len : felt, data : felt*
):
    ERC721_safeTransferFrom(_from, to, token_id, data_len, data)
    return ()
end

########################IExerciceSolution###############################
@external
func declare_animal{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    sex : felt, legs : felt, wings : felt) -> (token_id : Uint256):
    alloc_locals
    # Reading caller address
    let (sender_address) = get_caller_address()
    let (token_id) = cur_token_id.read()
    let (next_token_id, _) = uint256_add(token_id, Uint256(1,0))
    declare_animal_internal(next_token_id,sex,legs,wings)
    ERC721_mint(sender_address, next_token_id)
    return (next_token_id)
end

@external
func declare_dead_animal{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(token_id : Uint256):
    ERC721_burn(token_id)
    return ()
end