shape theory.computing.network : theory.computing.peripheral, theory.contact.mutual {
  type: structure
  layer: 0
  """
// Network Protocol Stack.
//
// The network is mutual contact between computers: each
// computer's character enters the other's transformation.
// The protocol stack is the contact geometry: the structure
// governing how character crosses the boundary.
//
// Idealized 5-layer model (each layer is an emergence layer):
//
// Layer 1: PHYSICAL
//   Bits on a wire (or fiber, or radio).
//   Encoding: voltage levels, light pulses, RF modulation.
//   The raw channel. No addressing, no error handling.
//   Just: send bit, receive bit.
//
// Layer 2: LINK
//   Frames: [header | payload | checksum].
//   Header: source MAC, destination MAC, type, length.
//   MAC address: 48-bit hardware address, globally unique.
//   Checksum (CRC-32): detects corruption. Corrupted frames
//     are dropped (incoherent character is dissolved, Law 0).
//   Switching: link-layer switches forward frames based on
//     MAC address table. Learning: switch records which port
//     each MAC appears on.
//   The link layer provides reliable hop-by-hop delivery.
//
// Layer 3: NETWORK
//   Packets: [IP header | payload].
//   IP address: 128-bit (IPv6), hierarchically assigned.
//   Routing: each router maintains a forwarding table.
//     Packet arrives, router looks up destination prefix,
//     forwards to next hop. Routing protocols (BGP, OSPF)
//     build forwarding tables by exchanging reachability info.
//   TTL (Time To Live): decremented each hop. Reaches 0 =
//     packet dropped. Prevents infinite loops (Law 1: references
//     must be bounded).
//   Fragmentation: large packets split for links with smaller MTU.
//   The network layer provides end-to-end addressing and routing.
//
// Layer 4: TRANSPORT
//   Segments: [transport header | payload].
//   Port numbers: 16-bit, demultiplex to applications.
//     (source port, dest port) = application-level addressing.
//
//   TCP (reliable stream):
//     Connection-oriented: 3-way handshake (SYN, SYN-ACK, ACK).
//     Sequence numbers: each byte numbered. Receiver ACKs
//       received bytes. Sender retransmits unacked bytes.
//     Flow control: receiver advertises window (how much it
//       can accept). Sender doesn't exceed window.
//     Congestion control: sender probes network capacity.
//       Slow start, congestion avoidance, fast retransmit.
//     Ordered delivery: receiver reorders and delivers in sequence.
//     TCP provides reliable, ordered, flow-controlled byte stream.
//     This is coherence maintenance across unreliable contact:
//     every byte is accounted for (Law 2), ordering is preserved
//     (Law 1), and congestion is resolved (Law 3).
//
//   UDP (unreliable datagram):
//     No connection, no reliability, no ordering.
//     Just: send datagram, hope it arrives.
//     Used when speed > reliability (video, gaming, DNS).
//
// Layer 5: APPLICATION
//   The application protocol: HTTP, DNS, SSH, SMTP, etc.
//   Each defines the structure of the conversation:
//     HTTP: request (method, URL, headers, body) ->
//       response (status, headers, body).
//     DNS: query (name) -> response (address).
//     SSH: encrypted bidirectional channel.
//   The application protocol is the contact geometry between
//   two applications running on different computers.
//
// Derives from: theory.computing.peripheral, theory.contact.mutual
  """
}
