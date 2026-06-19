#! /usr/bin/env python3

import argparse
import collections
import math
import re
import sys
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

# Some MiniPhy trees may be large. Recursive traversal is simple here, so keep a
# high limit as the previous ETE3-based script already did.
sys.setrecursionlimit(500000)

Name = Optional[str]
Length = Optional[float]
Signature = Tuple


def info(*msg):
    print(*msg, file=sys.stderr)


class NewickError(ValueError):
    """Input or processing error that should be reported cleanly to the user."""


@dataclass
class RawNode:
    # Direct representation of the Newick input before unrooting.
    name: Name = None
    length: Length = None
    children: List["RawNode"] = field(default_factory=list)


@dataclass
class OutNode:
    # Rooted display tree used only for deterministic Newick serialization.
    name: Name = None
    length: Length = None
    children: List["OutNode"] = field(default_factory=list)


class Graph:
    """Small undirected tree graph.

    Newick has a root because the text is nested, but MiniPhy wants to treat the
    phylogeny as unrooted. This graph is the root-free representation.
    """

    def __init__(self):
        self.names: Dict[int, Name] = {}
        self.adj: Dict[int, Dict[int, Length]] = {}
        self._next_id = 0

    def add_node(self, name: Name) -> int:
        node_id = self._next_id
        self._next_id += 1
        self.names[node_id] = name
        self.adj[node_id] = {}
        return node_id

    def add_edge(self, a: int, b: int, length: Length) -> None:
        self.adj[a][b] = length
        self.adj[b][a] = length

    def remove_edge(self, a: int, b: int) -> None:
        del self.adj[a][b]
        del self.adj[b][a]

    def remove_node(self, node_id: int) -> None:
        for nb in list(self.adj[node_id]):
            del self.adj[nb][node_id]
        del self.adj[node_id]
        del self.names[node_id]

    def nodes(self) -> List[int]:
        return list(self.adj.keys())

    def edges(self) -> List[Tuple[int, int, Length]]:
        out = []
        for a in sorted(self.adj):
            for b, length in self.adj[a].items():
                if a < b:
                    out.append((a, b, length))
        return out

    def degree(self, node_id: int) -> int:
        return len(self.adj[node_id])

    def edge_length(self, a: int, b: int) -> Length:
        return self.adj[a][b]


class NewickParser:
    """Minimal Newick parser for plain trees.

    It supports leaf/internal names, branch lengths, quoted labels, comments in
    square brackets, and a final semicolon. It deliberately avoids ETE3.
    """

    def __init__(self, text: str):
        self.text = text
        self.i = 0

    def parse(self) -> RawNode:
        self._skip_ws_comments()
        if self._at_end():
            raise NewickError("empty Newick input")
        root = self._parse_subtree()
        self._skip_ws_comments()
        if not self._at_end() and self.text[self.i] == ";":
            self.i += 1
        self._skip_ws_comments()
        if not self._at_end():
            raise NewickError(f"unexpected trailing text at position {self.i}")
        return root

    def _at_end(self) -> bool:
        return self.i >= len(self.text)

    def _peek(self) -> str:
        if self._at_end():
            return ""
        return self.text[self.i]

    def _skip_ws_comments(self) -> None:
        while not self._at_end():
            c = self.text[self.i]
            if c.isspace():
                self.i += 1
                continue
            if c == "[":
                self.i += 1
                while not self._at_end() and self.text[self.i] != "]":
                    self.i += 1
                if self._at_end():
                    raise NewickError("unterminated Newick comment")
                self.i += 1
                continue
            break

    def _parse_subtree(self) -> RawNode:
        self._skip_ws_comments()
        if self._peek() == "(":
            self.i += 1
            children = []
            while True:
                children.append(self._parse_subtree())
                self._skip_ws_comments()
                c = self._peek()
                if c == ",":
                    self.i += 1
                    continue
                if c == ")":
                    self.i += 1
                    break
                raise NewickError(f"expected ',' or ')' at position {self.i}")
            name = self._parse_label(required=False)
            length = self._parse_length()
            return RawNode(name=name, length=length, children=children)

        name = self._parse_label(required=True)
        length = self._parse_length()
        return RawNode(name=name, length=length, children=[])

    def _parse_label(self, required: bool) -> Name:
        self._skip_ws_comments()
        if self._at_end():
            if required:
                raise NewickError("unexpected end while reading node name")
            return None

        c = self._peek()
        if c in ":,);":
            if required:
                raise NewickError(f"missing leaf name at position {self.i}")
            return None

        if c == "'":
            self.i += 1
            parts = []
            while not self._at_end():
                c = self.text[self.i]
                if c == "'":
                    if self.i + 1 < len(
                            self.text) and self.text[self.i + 1] == "'":
                        parts.append("'")
                        self.i += 2
                        continue
                    self.i += 1
                    label = "".join(parts)
                    if required and label == "":
                        raise NewickError("empty leaf name")
                    return label
                parts.append(c)
                self.i += 1
            raise NewickError("unterminated quoted node name")

        start = self.i
        while not self._at_end():
            c = self.text[self.i]
            if c in ":,();[]" or c.isspace():
                break
            self.i += 1
        label = self.text[start:self.i].strip()
        if required and label == "":
            raise NewickError(f"missing leaf name at position {start}")
        return label or None

    def _parse_length(self) -> Length:
        self._skip_ws_comments()
        if self._peek() != ":":
            return None
        self.i += 1
        self._skip_ws_comments()
        start = self.i
        while not self._at_end():
            c = self.text[self.i]
            if c in ",);[]" or c.isspace():
                break
            self.i += 1
        token = self.text[start:self.i]
        if token == "":
            raise NewickError(f"missing branch length at position {start}")
        try:
            value = float(token)
        except ValueError as e:
            raise NewickError(f"invalid branch length '{token}'") from e
        if not math.isfinite(value):
            raise NewickError(f"invalid non-finite branch length '{token}'")
        if value < 0:
            raise NewickError(f"negative branch length '{token}'")
        return value


def parse_newick_file(path: str) -> RawNode:
    with open(path, "r") as f:
        return NewickParser(f.read()).parse()


def raw_tree_to_graph(root: RawNode) -> Graph:
    # Convert nested Newick to an undirected graph. After this point, input root
    # placement and child order are no longer trusted.
    graph = Graph()

    def add_raw(node: RawNode) -> int:
        node_id = graph.add_node(node.name)
        for child in node.children:
            child_id = add_raw(child)
            graph.add_edge(node_id, child_id, child.length)
        return node_id

    root_id = add_raw(root)
    suppress_original_root_if_needed(graph, root_id)
    return graph


def combine_suppressed_root_lengths(a: Length, b: Length) -> Length:
    # If a rooted binary Newick has a degree-2 artificial root, remove it and
    # merge its two adjacent edges. Mixed length/no-length edges stay undefined.
    if a is None and b is None:
        return None
    if a is not None and b is not None:
        return a + b
    return None


def suppress_original_root_if_needed(graph: Graph, root_id: int) -> None:
    # A rooted binary tree usually has a degree-2 root. Suppressing it is what
    # makes the input tree unrooted.
    if root_id not in graph.adj:
        return
    if graph.degree(root_id) != 2:
        return

    neighbors = list(graph.adj[root_id].items())
    (a, len_a), (b, len_b) = neighbors
    new_length = combine_suppressed_root_lengths(len_a, len_b)
    graph.remove_node(root_id)
    graph.add_edge(a, b, new_length)


def leaf_ids(graph: Graph) -> List[int]:
    if len(graph.adj) == 1:
        return list(graph.adj.keys())
    return [node_id for node_id in graph.adj if graph.degree(node_id) == 1]


def validate_unrooted_binary(graph: Graph) -> None:
    # Do not imitate ETE3 standardize(). We want bad trees to fail instead of
    # silently resolving polytomies or suppressing arbitrary unary nodes.
    if not graph.adj:
        raise NewickError("empty tree")

    leaves = leaf_ids(graph)
    if not leaves:
        raise NewickError("tree has no leaves")

    leaf_names = []
    for node_id in leaves:
        name = graph.names[node_id]
        if name is None or name == "":
            raise NewickError("all leaves must have non-empty names")
        leaf_names.append(name)

    counts = collections.Counter(leaf_names)
    duplicates = sorted(name for name, count in counts.items() if count > 1)
    if duplicates:
        dup = ", ".join(duplicates[:5])
        raise NewickError(f"duplicate leaf names are not supported: {dup}")

    if len(graph.adj) == 1:
        return

    if len(leaves) == 2 and len(graph.adj) == 2:
        for node_id in graph.adj:
            if graph.degree(node_id) != 1:
                raise NewickError("invalid two-leaf tree")
        return

    for node_id in graph.adj:
        deg = graph.degree(node_id)
        if deg == 1:
            continue
        if deg != 3:
            raise NewickError(
                "input tree is not a fully bifurcating unrooted tree; "
                "polytomies and unary internal nodes are not supported")


def directed_component_signature(graph: Graph):
    # A signature describes the topology and leaf names seen when entering an
    # edge from one side. Sorting by signatures gives deterministic rotations.
    memo: Dict[Tuple[int, int], Signature] = {}

    def signature(parent: int, node: int) -> Signature:
        key = (parent, node)
        if key in memo:
            return memo[key]
        children = [nb for nb in graph.adj[node] if nb != parent]
        if not children:
            name = graph.names[node]
            if name is None:
                raise NewickError("leaf without a name")
            sig: Signature = ("L", name)
        else:
            sig = ("I",
                   tuple(sorted(signature(node, child) for child in children)))
        memo[key] = sig
        return sig

    return signature


def choose_canonical_root_edge(graph: Graph) -> Tuple[int, int]:
    # Default mode needs a display root for Newick output. Pick the edge whose
    # two-side signatures are lexicographically smallest. This is deterministic
    # and independent of the input root/rotations.
    edges = graph.edges()
    if not edges:
        raise NewickError("cannot choose a root edge for a one-node tree")

    signature = directed_component_signature(graph)
    candidates = []
    for a, b, _length in edges:
        s1 = signature(a, b)
        s2 = signature(b, a)
        edge_signature = tuple(sorted((s1, s2)))
        candidates.append((edge_signature, a, b))
    candidates.sort(key=lambda x: x[0])
    return candidates[0][1], candidates[0][2]


def edge_split_lengths(length: Length) -> Tuple[Length, Length]:
    # A display root is inserted on an existing edge. Splitting the edge 50/50
    # keeps all leaf-to-leaf distances unchanged.
    if length is None:
        return None, None
    return length / 2.0, length / 2.0


def build_default_output_tree(graph: Graph) -> OutNode:
    # Default mode: canonicalize by unweighted topology and leaf names only.
    # Branch lengths are preserved, but ignored for ordering.
    if len(graph.adj) == 1:
        node_id = next(iter(graph.adj))
        return OutNode(name=graph.names[node_id])

    a, b = choose_canonical_root_edge(graph)
    length = graph.edge_length(a, b)
    len1, len2 = edge_split_lengths(length)
    signature = directed_component_signature(graph)

    sides = [
        (signature(b, a), b, a, len1),
        (signature(a, b), a, b, len2),
    ]
    sides.sort(key=lambda x: x[0])

    root = OutNode(name=None, length=None)
    root.children = [
        build_subtree(
            graph,
            parent=parent,
            node=node,
            length=child_length,
            mode="default",
            signature=signature,
        ) for _sig, parent, node, child_length in sides
    ]
    return root


def find_path(graph: Graph, start: int, end: int) -> List[int]:
    # Unique path in a tree, used to keep the diameter endpoint on the far right.
    stack = [(start, None)]
    parent: Dict[int, Optional[int]] = {start: None}
    while stack:
        node, _ = stack.pop()
        if node == end:
            break
        for nb in graph.adj[node]:
            if nb not in parent:
                parent[nb] = node
                stack.append((nb, node))
    if end not in parent:
        raise NewickError("tree is disconnected")
    path = []
    node: Optional[int] = end
    while node is not None:
        path.append(node)
        node = parent[node]
    path.reverse()
    return path


def branch_length_mode(graph: Graph) -> str:
    # --max-diameter may use weights, but only when the whole tree is weighted.
    lengths = [length for _a, _b, length in graph.edges()]
    have = [length is not None for length in lengths]
    if all(have):
        return "weighted"
    if not any(have):
        return "unweighted"
    return "mixed"


def find_diameter_pair(graph: Graph) -> Tuple[int, int]:
    # Pick a reproducible farthest leaf pair. Ties are broken by leaf names.
    leaves = leaf_ids(graph)
    if len(leaves) == 1:
        return leaves[0], leaves[0]
    if len(leaves) == 2:
        a, b = sorted(leaves, key=lambda node_id: graph.names[node_id])
        return a, b

    mode = branch_length_mode(graph)
    if mode == "mixed":
        raise NewickError(
            "--max-diameter requires either all branch lengths or no branch lengths; "
            "mixed weighted/unweighted trees are not supported")

    def weight(a: int, b: int) -> float:
        if mode == "weighted":
            length = graph.edge_length(a, b)
            assert length is not None
            return length
        return 1.0

    # For every directed edge, store the best leaf reachable on that side.
    memo: Dict[Tuple[int, int], Tuple[float, str, int]] = {}

    def best_leaf(parent: int, node: int) -> Tuple[float, str, int]:
        key = (parent, node)
        if key in memo:
            return memo[key]
        children = [nb for nb in graph.adj[node] if nb != parent]
        if not children:
            name = graph.names[node]
            if name is None:
                raise NewickError("leaf without a name")
            result = (0.0, name, node)
        else:
            candidates = []
            for child in children:
                dist, name, leaf = best_leaf(node, child)
                candidates.append((dist + weight(node, child), name, leaf))
            candidates.sort(key=lambda x: (-x[0], x[1]))
            result = candidates[0]
        memo[key] = result
        return result

    best_pair: Optional[Tuple[float, Tuple[str, str], int, int]] = None

    # Evaluate all leaf pairs whose path passes through each graph node. This is
    # linear in the number of directed edges after memoization.
    for center in graph.nodes():
        candidates = []
        for nb in graph.adj[center]:
            dist, name, leaf = best_leaf(center, nb)
            candidates.append((dist + weight(center, nb), name, leaf))

        if len(candidates) < 2:
            continue

        for i in range(len(candidates)):
            for j in range(i + 1, len(candidates)):
                d1, n1, l1 = candidates[i]
                d2, n2, l2 = candidates[j]
                pair_names = tuple(sorted((n1, n2)))
                candidate = (d1 + d2, pair_names, l1, l2)
                if best_pair is None:
                    best_pair = candidate
                    continue
                if candidate[0] > best_pair[0]:
                    best_pair = candidate
                elif candidate[0] == best_pair[0] and candidate[1] < best_pair[
                        1]:
                    best_pair = candidate

    if best_pair is None:
        raise NewickError("could not determine tree diameter")

    _dist, pair_names, l1, l2 = best_pair
    name1 = graph.names[l1]
    name2 = graph.names[l2]
    assert name1 is not None and name2 is not None
    if (name1, name2) == pair_names:
        return l1, l2
    return l2, l1


def build_max_diameter_output_tree(graph: Graph) -> OutNode:
    # Diameter mode: display-root next to the first endpoint and keep the path to
    # the second endpoint as the last child at each path node. This makes the two
    # diameter endpoints first and last in the output leaf order.
    if len(graph.adj) == 1:
        node_id = next(iter(graph.adj))
        return OutNode(name=graph.names[node_id])

    endpoint_a, endpoint_b = find_diameter_pair(graph)
    if endpoint_a == endpoint_b:
        return OutNode(name=graph.names[endpoint_a])

    path = find_path(graph, endpoint_a, endpoint_b)
    if len(path) < 2:
        raise NewickError("invalid diameter path")

    neighbor = path[1]
    length = graph.edge_length(endpoint_a, neighbor)
    len1, len2 = edge_split_lengths(length)
    path_next = {path[i]: path[i + 1] for i in range(len(path) - 1)}
    signature = directed_component_signature(graph)

    root = OutNode(name=None, length=None)
    root.children = [
        build_subtree(
            graph,
            parent=neighbor,
            node=endpoint_a,
            length=len1,
            mode="max-diameter",
            path_next=path_next,
            signature=signature,
        ),
        build_subtree(
            graph,
            parent=endpoint_a,
            node=neighbor,
            length=len2,
            mode="max-diameter",
            path_next=path_next,
            signature=signature,
        ),
    ]
    return root


def build_subtree(
    graph: Graph,
    parent: int,
    node: int,
    length: Length,
    mode: str,
    path_next: Optional[Dict[int, int]] = None,
    signature=None,
) -> OutNode:
    # Re-rooted output builder. In default mode, all children are sorted by their
    # component signatures. In diameter mode, the path to the far endpoint is
    # forced to be last, and all off-path branches are sorted canonically.
    out = OutNode(name=graph.names[node], length=length)
    children = [nb for nb in graph.adj[node] if nb != parent]
    if not children:
        return out

    if signature is None:
        signature = directed_component_signature(graph)

    if mode == "max-diameter" and path_next is not None:
        next_on_path = path_next.get(node)
        if next_on_path in children:
            off_path = [child for child in children if child != next_on_path]
            off_path.sort(key=lambda child: signature(node, child))
            ordered_children = off_path + [next_on_path]
        else:
            ordered_children = sorted(children,
                                      key=lambda child: signature(node, child))
    else:
        ordered_children = sorted(children,
                                  key=lambda child: signature(node, child))

    out.children = [
        build_subtree(
            graph,
            parent=node,
            node=child,
            length=graph.edge_length(node, child),
            mode=mode,
            path_next=path_next,
            signature=signature,
        ) for child in ordered_children
    ]
    return out


def iter_postorder(root: OutNode):
    for child in root.children:
        yield from iter_postorder(child)
    yield root


def iter_preorder(root: OutNode):
    yield root
    for child in root.children:
        yield from iter_preorder(child)


def iter_leaves(root: OutNode):
    if not root.children:
        yield root
        return
    for child in root.children:
        yield from iter_leaves(child)


def name_internal_nodes(root: OutNode, overwrite: bool = True) -> None:
    # Name internal nodes after canonicalization, so names are deterministic and
    # do not depend on whatever names/order the input Newick had.
    re_inferred = re.compile(r"^(.*)-up(\d+)$")
    used = {leaf.name for leaf in iter_leaves(root) if leaf.name}

    for node in iter_postorder(root):
        if not node.children:
            if node.name is None or node.name == "":
                raise NewickError("all leaves must have non-empty names")
            continue

        if node.name and not overwrite:
            used.add(node.name)
            continue

        child_names = [child.name for child in node.children]
        if any(name is None or name == "" for name in child_names):
            raise NewickError(
                "cannot name internal node before its children are named")

        min_name = sorted(child_names)[0]
        m = re_inferred.match(min_name)
        if m is not None:
            base, number = m.groups()
            candidate = f"{base}-up{int(number) + 1}"
        else:
            candidate = f"{min_name}-up1"

        while candidate in used:
            m = re_inferred.match(candidate)
            if m is not None:
                base, number = m.groups()
                candidate = f"{base}-up{int(number) + 1}"
            else:
                candidate = f"{candidate}-up1"

        node.name = candidate
        used.add(candidate)


def assert_named_nodes_for_output(root: OutNode, only_leaves: bool) -> None:
    # The leaves/nodes order files are consumed later. Avoid unnamed records.
    iterator = iter_leaves(root) if only_leaves else iter_preorder(root)
    for node in iterator:
        if node.name is None or node.name == "":
            raise NewickError(
                "empty node name in output; use --name-internals")
        if node.name == "merge_root":
            raise NewickError("invalid output node name: merge_root")


def write_nodes(root: OutNode, path: str, only_leaves: bool) -> None:
    assert_named_nodes_for_output(root, only_leaves=only_leaves)
    iterator = iter_leaves(root) if only_leaves else iter_preorder(root)
    with open(path, "w") as f:
        for node in iterator:
            f.write(f"{node.name}\n")


def quote_name(name: Name) -> str:
    if name is None or name == "":
        return ""
    if re.match(r"^[A-Za-z0-9_.|/+=@-]+$", name):
        return name
    return "'" + name.replace("'", "''") + "'"


def format_length(length: Length) -> str:
    if length is None:
        return ""
    if abs(length) < 1e-15:
        length = 0.0
    return ":" + format(length, ".12g")


def to_newick(node: OutNode, is_root: bool = False) -> str:
    # Write a plain Newick tree. The top-level root has no branch length.
    if node.children:
        body = "(" + ",".join(to_newick(child)
                              for child in node.children) + ")"
        body += quote_name(node.name)
    else:
        if node.name is None or node.name == "":
            raise NewickError("leaf without a name")
        body = quote_name(node.name)

    if not is_root:
        body += format_length(node.length)
    return body


def write_newick(root: OutNode, path: str) -> None:
    with open(path, "w") as f:
        f.write(to_newick(root, is_root=True) + ";\n")


def run(in_tree_fn, out_tree_fn, name_internals, max_diameter, leaves_fn,
        nodes_fn):
    # Main pipeline:
    #   1. parse rooted-looking Newick
    #   2. discard the input root by using an undirected graph
    #   3. validate strict unrooted binary topology
    #   4. create a deterministic display rooting/rotation
    #   5. optionally name internals and write outputs
    raw_root = parse_newick_file(in_tree_fn)
    graph = raw_tree_to_graph(raw_root)
    validate_unrooted_binary(graph)

    if max_diameter:
        info(
            "Canonicalizing unrooted tree with maximum-diameter endpoint ordering"
        )
        out_root = build_max_diameter_output_tree(graph)
    else:
        info("Canonicalizing unrooted tree by topology and leaf names")
        out_root = build_default_output_tree(graph)

    if name_internals:
        info("Automatic deterministic naming of internal nodes")
        name_internal_nodes(out_root, overwrite=True)

    write_newick(out_root, out_tree_fn)

    if leaves_fn:
        write_nodes(out_root, leaves_fn, only_leaves=True)
    if nodes_fn:
        write_nodes(out_root, nodes_fn, only_leaves=False)


def main():
    parser = argparse.ArgumentParser(description=(
        "Canonicalize a Newick tree without ETE3. The input root is ignored; "
        "the tree is treated as an unrooted binary tree."))
    parser.add_argument(
        "in_tree_fn",
        metavar="input.tree.nw",
        help="Input Newick tree",
    )
    parser.add_argument(
        "out_tree_fn",
        metavar="output.tree.nw",
        help="Output Newick tree",
    )
    parser.add_argument(
        "--name-internals",
        dest="name_internals",
        help="Deterministically name all internal nodes",
        action="store_true",
    )
    parser.add_argument(
        "--max-diameter",
        dest="max_diameter",
        help=
        ("Orient output so the first and last leaves are a deterministic "
         "maximum-diameter pair. Uses branch lengths only if all edges have them; "
         "otherwise uses unweighted distances."),
        action="store_true",
    )
    parser.add_argument(
        "-l",
        "--leaves",
        metavar="leaves_order.txt",
        dest="leaves_fn",
        help="Print leaves in output order",
    )
    parser.add_argument(
        "-n",
        "--nodes",
        metavar="nodes_order.txt",
        dest="nodes_fn",
        help="Print nodes in preorder output order",
    )

    args = parser.parse_args()

    try:
        run(
            in_tree_fn=args.in_tree_fn,
            out_tree_fn=args.out_tree_fn,
            name_internals=args.name_internals,
            max_diameter=args.max_diameter,
            leaves_fn=args.leaves_fn,
            nodes_fn=args.nodes_fn,
        )
    except NewickError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
