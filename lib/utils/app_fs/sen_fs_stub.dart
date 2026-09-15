import 'sen_fs.dart';
import 'sen_fs_memory.dart';

/// Web default backend. Each export installs its own [MemorySenIo] via
/// [runWithSenIo]; this default just keeps [senIo] non-null off the VM.
SenIo createDefaultSenIo() => MemorySenIo();
