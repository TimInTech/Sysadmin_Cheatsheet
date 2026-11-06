using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;

namespace RemoteHelp
{
    // The owner must remain alive for as long as its child is needed.
    public sealed class JobSupervisor : IDisposable
    {
        private SafeFileHandle job;
        public int ProcessId { get; private set; }

        private JobSupervisor(SafeFileHandle jobHandle, int processId)
        {
            job = jobHandle;
            ProcessId = processId;
        }

        public void Dispose()
        {
            if (job != null) { job.Dispose(); job = null; }
        }

        // Arguments are supplied by trusted code; never include credentials.
        public static JobSupervisor Start(string executable, string arguments)
        {
            if (String.IsNullOrWhiteSpace(executable) || executable.IndexOf('"') >= 0)
                throw new ArgumentException("An unquoted executable path is required.", "executable");
            SafeFileHandle handle = CreateJobObject(IntPtr.Zero, null);
            if (handle.IsInvalid) { int error = Marshal.GetLastWin32Error(); handle.Dispose(); throw new Win32Exception(error); }
            IntPtr attributes = IntPtr.Zero;
            IntPtr jobList = IntPtr.Zero;
            bool initialized = false;
            bool success = false;
            try
            {
                ExtendedLimits limits = new ExtendedLimits();
                limits.BasicLimitInformation.LimitFlags = 0x00002000; // KILL_ON_JOB_CLOSE
                int size = Marshal.SizeOf(typeof(ExtendedLimits));
                IntPtr limitBuffer = Marshal.AllocHGlobal(size);
                try
                {
                    Marshal.StructureToPtr(limits, limitBuffer, false);
                    if (!SetInformationJobObject(handle, 9, limitBuffer, (uint)size)) ThrowLastError();
                }
                finally { Marshal.FreeHGlobal(limitBuffer); }

                IntPtr attributeBytes = IntPtr.Zero;
                InitializeProcThreadAttributeList(IntPtr.Zero, 1, 0, ref attributeBytes);
                if (attributeBytes == IntPtr.Zero) ThrowLastError();
                attributes = Marshal.AllocHGlobal(attributeBytes);
                if (!InitializeProcThreadAttributeList(attributes, 1, 0, ref attributeBytes)) ThrowLastError();
                initialized = true;
                jobList = Marshal.AllocHGlobal(IntPtr.Size);
                Marshal.WriteIntPtr(jobList, handle.DangerousGetHandle());
                if (!UpdateProcThreadAttribute(attributes, 0, (IntPtr)0x0002000D, jobList, (IntPtr)IntPtr.Size, IntPtr.Zero, IntPtr.Zero)) ThrowLastError();

                StartupInfoEx startup = new StartupInfoEx();
                startup.StartupInfo.cb = Marshal.SizeOf(typeof(StartupInfoEx));
                startup.AttributeList = attributes;
                ProcessInformation process;
                StringBuilder command = new StringBuilder("\"" + executable + "\" " + (arguments ?? ""));
                if (!CreateProcess(executable, command, IntPtr.Zero, IntPtr.Zero, false, 0x00080000, IntPtr.Zero, null, ref startup, out process)) ThrowLastError();
                try
                {
                    success = true;
                    return new JobSupervisor(handle, process.ProcessId);
                }
                finally { CloseHandle(process.Thread); CloseHandle(process.Process); }
            }
            finally
            {
                if (initialized) DeleteProcThreadAttributeList(attributes);
                if (attributes != IntPtr.Zero) Marshal.FreeHGlobal(attributes);
                if (jobList != IntPtr.Zero) Marshal.FreeHGlobal(jobList);
                if (!success) handle.Dispose();
            }
        }

        private static void ThrowLastError() { throw new Win32Exception(Marshal.GetLastWin32Error()); }
        [StructLayout(LayoutKind.Sequential)] private struct BasicLimits
        {
            public long PerProcessUserTimeLimit, PerJobUserTimeLimit;
            public uint LimitFlags;
            public UIntPtr MinimumWorkingSetSize, MaximumWorkingSetSize;
            public uint ActiveProcessLimit;
            public UIntPtr Affinity;
            public uint PriorityClass, SchedulingClass;
        }
        [StructLayout(LayoutKind.Sequential)] private struct IoCounters
        { public ulong ReadOperationCount, WriteOperationCount, OtherOperationCount, ReadTransferCount, WriteTransferCount, OtherTransferCount; }
        [StructLayout(LayoutKind.Sequential)] private struct ExtendedLimits
        {
            public BasicLimits BasicLimitInformation;
            public IoCounters IoInfo;
            public UIntPtr ProcessMemoryLimit, JobMemoryLimit, PeakProcessMemoryUsed, PeakJobMemoryUsed;
        }
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)] private struct StartupInfo
        {
            public int cb;
            public string Reserved, Desktop, Title;
            public uint X, Y, XSize, YSize, XCountChars, YCountChars, FillAttribute, Flags;
            public short ShowWindow, Reserved2;
            public IntPtr Reserved2Pointer, StdInput, StdOutput, StdError;
        }
        [StructLayout(LayoutKind.Sequential)] private struct StartupInfoEx { public StartupInfo StartupInfo; public IntPtr AttributeList; }
        [StructLayout(LayoutKind.Sequential)] private struct ProcessInformation { public IntPtr Process, Thread; public int ProcessId, ThreadId; }

        [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] private static extern SafeFileHandle CreateJobObject(IntPtr attributes, string name);
        [DllImport("kernel32.dll", SetLastError=true)] private static extern bool SetInformationJobObject(SafeFileHandle job, int infoClass, IntPtr info, uint length);
        [DllImport("kernel32.dll", SetLastError=true)] private static extern bool InitializeProcThreadAttributeList(IntPtr list, int count, int flags, ref IntPtr size);
        [DllImport("kernel32.dll", SetLastError=true)] private static extern bool UpdateProcThreadAttribute(IntPtr list, uint flags, IntPtr attribute, IntPtr value, IntPtr size, IntPtr previous, IntPtr returned);
        [DllImport("kernel32.dll")] private static extern void DeleteProcThreadAttributeList(IntPtr list);
        [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] private static extern bool CreateProcess(string application, StringBuilder command, IntPtr processAttributes, IntPtr threadAttributes, bool inheritHandles, uint flags, IntPtr environment, string directory, ref StartupInfoEx startup, out ProcessInformation process);
        [DllImport("kernel32.dll", SetLastError=true)] private static extern bool CloseHandle(IntPtr handle);
    }
}
