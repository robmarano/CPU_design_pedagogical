import sys
import re

def assemble(input_file, output_file):
    opcodes = {
        'add':  (0x00, 0x20, 'R'),
        'sub':  (0x00, 0x22, 'R'),
        'and':  (0x00, 0x24, 'R'),
        'or':   (0x00, 0x25, 'R'),
        'slt':  (0x00, 0x2a, 'R'),
        'addi': (0x08, None, 'I'),
        'lw':   (0x23, None, 'I_mem'),
        'sw':   (0x2b, None, 'I_mem'),
        'beq':  (0x04, None, 'I_br'),
        'bne':  (0x05, None, 'I_br'),
        'j':    (0x02, None, 'J')
    }

    def reg(s):
        s = s.replace(',', '').replace('$', '').strip()
        if s == 'zero': return 0
        if s.startswith('t') and len(s)==2: return 8 + int(s[1]) if int(s[1]) < 8 else 24 + int(s[1]) - 8
        if s.startswith('s') and len(s)==2: return 16 + int(s[1])
        if s.startswith('a') and len(s)==2: return 4 + int(s[1])
        if s.startswith('v') and len(s)==2: return 2 + int(s[1])
        return int(s)

    lines = []
    with open(input_file, 'r') as f:
        for line in f:
            line = line.split('#')[0].strip()
            if line: lines.append(line)

    labels = {}
    instructions = []
    addr = 0
    for line in lines:
        if ':' in line:
            label, rest = line.split(':', 1)
            labels[label.strip()] = addr
            if rest.strip():
                instructions.append((addr, rest.strip()))
                addr += 4
        else:
            instructions.append((addr, line))
            addr += 4

    machine_code = []
    for addr, inst in instructions:
        parts = re.split(r'[\s,()]+', inst)
        parts = [p for p in parts if p]
        mnem = parts[0]
        
        if mnem not in opcodes:
            print(f"Error: Unknown instruction {mnem}")
            sys.exit(1)
            
        op, funct, typ = opcodes[mnem]
        
        if typ == 'R':
            # add rd, rs, rt
            rd = reg(parts[1])
            rs = reg(parts[2])
            rt = reg(parts[3])
            code = (op << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (0 << 6) | funct
        elif typ == 'I':
            # addi rt, rs, imm
            rt = reg(parts[1])
            rs = reg(parts[2])
            imm = int(parts[3]) & 0xFFFF
            code = (op << 26) | (rs << 21) | (rt << 16) | imm
        elif typ == 'I_mem':
            # lw rt, imm(rs)
            rt = reg(parts[1])
            imm = int(parts[2]) & 0xFFFF
            rs = reg(parts[3])
            code = (op << 26) | (rs << 21) | (rt << 16) | imm
        elif typ == 'I_br':
            # beq rs, rt, label
            rs = reg(parts[1])
            rt = reg(parts[2])
            target = parts[3]
            if target in labels:
                # offset is relative to PC+4
                offset = (labels[target] - (addr + 4)) // 4
            else:
                offset = int(target)
            offset = offset & 0xFFFF
            code = (op << 26) | (rs << 21) | (rt << 16) | offset
        elif typ == 'J':
            # j label
            target = parts[1]
            if target in labels:
                t_addr = labels[target] // 4
            else:
                t_addr = int(target)
            code = (op << 26) | (t_addr & 0x03FFFFFF)

        machine_code.append(f"{code:08x}")

    with open(output_file, 'w') as f:
        for c in machine_code:
            f.write(c + '\n')
    print(f"Assembled {len(machine_code)} instructions to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python assembler.py <input.asm> <output.dat>")
        sys.exit(1)
    assemble(sys.argv[1], sys.argv[2])
